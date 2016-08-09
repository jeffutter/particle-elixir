defmodule Particle.Stream do
  alias Particle.Http
  require Logger

  @moduledoc false

  @doc """
  The default timeout value (in milliseconds) for how long keeps waiting until next message arrives.
  """
  @default_stream_timeout 60_000
  @default_control_timeout 10_000

  def create_stream(url, timeout \\ @default_stream_timeout) do
    Stream.resource(
      fn ->
        {url, nil}
      end,
      fn({url, pid}) ->
        receive_next_event(pid, url, timeout)
      end,
      fn({_url, pid}) ->
        if pid != nil do
          send pid, {:cancel, self}
        end
      end
    )
  end

  def stream_control(pid, :stop, options \\ []) do
    timeout = options[:timeout] || @default_control_timeout

    send pid, {:control_stop, self}

    receive do
      :ok -> :ok
    after
      timeout -> :timeout
    end
  end


  defp receive_next_event(nil, url, timeout) do
    receive_next_event(spawn_async_request(url), url, timeout)
  end

  defp receive_next_event(pid, url, timeout) do
    max_timeout = case timeout do
                    :infinity -> @default_stream_timeout
                    _ -> timeout
                  end

    receive do
      {:stream, event} ->
        {[event], {url, pid}}

      {:control_stop, requester} ->
        send pid, {:cancel, self}
        send requester, :ok
        {:halt, {url, pid}}

      {:error, :socket_closed_remotely} ->
        Logger.warn "Connection closed remotely, restarting stream"
        receive_next_event(nil, url, timeout)

      _ ->
        receive_next_event(pid, url, timeout)
    after
      max_timeout ->
        send pid, {:cancel, self}
        case timeout do
          :infinity ->
            Logger.debug "Event timeout, restarting stream."
            receive_next_event(pid, url, timeout)
          _ ->
            Logger.debug "Event timeout, stopping stream."
            {:halt, {url, pid}}
        end
    end
  end

  defp spawn_async_request(url) do
    me = self
    spawn(fn ->
      case Http.get(url, %{}, [stream_to: self, recv_timeout: :infinity]) do
        {:ok, %HTTPoison.AsyncResponse{id: request_id}} ->
          process_stream(me, request_id)
        {:error, %HTTPoison.Error{reason: reason}} ->
          send me, {:error, reason}
      end
    end)
  end

  defp process_stream(processor, request_id, acc \\ %{event: nil, data: nil}) do
    receive do
      %HTTPoison.AsyncStatus{code: _code, id: request_id} ->
        send processor, :keepalive
        process_stream(processor, request_id)
      %HTTPoison.AsyncHeaders{headers: headers, id: request_id} ->
        Logger.debug "Stream Headers #{inspect headers}"
        send processor, :keepalive
        process_stream(processor, request_id)
      %HTTPoison.AsyncChunk{chunk: chunk, id: request_id} ->
        {processor, request_id, acc} = process_chunk(processor, request_id, chunk, acc)
        process_stream(processor, request_id, acc)
      %HTTPoison.Error{reason: reason, id: _request_id} ->
        Logger.debug "Stream Error"
        send processor, {:error, reason}
      %HTTPoison.AsyncRedirect{} ->
        Logger.debug "Stream Redirect"
        process_stream(processor, request_id)
      {:cancel, requester} ->
        Logger.debug "Canceling Stream"
        :hackney.cancel_request(request_id)
        send requester, :ok
      _ ->
        send processor, :keepalive
        process_stream(processor, request_id)
    end
  end

  defp process_chunk(processor, request_id, chunk, acc \\ %{event: nil, data: nil}) do
    {processor, request_id, acc} = cond do
      chunk == ""    ->
        send processor, :keepalive
        {processor, request_id, acc}
      chunk == ":ok" ->
        send processor, :keepalive
        {processor, request_id, acc}
      chunk =~ ~r/event: / ->
        %{"event" => event} = Regex.named_captures(~r/event: (?<event>.*)/, chunk)
        send processor, :keepalive
        {processor, request_id,  %{event: event, data: nil}}
      chunk =~ ~r/data: / ->
        %{"data" => data} = Regex.named_captures(~r/data: (?<data>.*)/, chunk)
        data = data
        |> Poison.decode!(keys: :atoms)
        |> Map.get(:data)
        send processor, {:stream, %{acc | data: data}}
        {processor, request_id,  %{event: nil, data: nil}}
      true ->
        send processor, :keepalive
        {processor, request_id, acc}
    end
    {processor, request_id, acc}
  end
end

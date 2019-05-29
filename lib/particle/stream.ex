defmodule Particle.Stream.Event do
  @moduledoc false
  defstruct event: nil, data: nil, ttl: nil, published_at: nil, coreid: nil
end

defmodule Particle.Stream do
  require Logger

  alias Particle.Stream.Event
  alias Particle.Http

  use GenStage

  @moduledoc false

  defstruct ref: nil, demand: 0, url: "", http_client: nil, event: %Event{}

  defdelegate stream(stages), to: GenStage
  defdelegate stop(stage, reason \\ :normal, timeout \\ :infinity), to: GenStage

  def start_link(url, http_client \\ Http, options \\ []) do
    GenStage.start_link(__MODULE__, {url, http_client}, options)
  end

  def init({url, http_client}) do
    {:ok, ref} = http_client.stream(url, self())
    {:producer, %__MODULE__{ref: ref, url: url, http_client: http_client}}
  end

  def handle_demand(
        demand,
        %__MODULE__{http_client: http_client, demand: previous_demand, ref: ref} = state
      )
      when demand > 0 do
    if previous_demand == 0, do: http_client.stream_next(ref)
    {:noreply, [], %__MODULE__{state | demand: previous_demand + demand}}
  end

  def handle_info(
        {:hackney_response, ref, {:status, status_code, reason}},
        %__MODULE__{demand: demand, http_client: http_client} = state
      ) do
    if status_code in 200..299 do
      if demand > 0, do: http_client.stream_next(ref)
      {:noreply, [], %__MODULE__{state | ref: ref}}
    else
      Logger.warn("Hackney Error: #{status_code} - #{inspect(reason)}")
      http_client.stream_next(ref)
      {:noreply, [], %__MODULE__{state | ref: ref}}
    end
  end

  def handle_info(
        {:hackney_response, _ref, {:headers, _headers}},
        %__MODULE__{http_client: http_client, ref: ref} = state
      ) do
    http_client.stream_next(ref)
    {:noreply, [], state}
  end

  def handle_info({:hackney_response, _ref, {:error, reason}}, state) do
    Logger.warn("Hackney Error: #{inspect(reason)}")
    {:stop, reason, state}
  end

  def handle_info({:hackney_response, _ref, :done}, state) do
    Logger.warn("Connection Closed")
    {:stop, "Connection Closed", state}
  end

  def handle_info(
        {:hackney_response, _ref, chunk},
        %__MODULE__{ref: ref, event: event, demand: demand, http_client: http_client} = state
      )
      when is_binary(chunk) do
    case event = process_chunk(chunk, event) do
      %Event{data: d, event: e} when not is_nil(d) and not is_nil(e) ->
        if demand > 0, do: http_client.stream_next(ref)
        {:noreply, [event], %__MODULE__{state | event: %Event{}, demand: max(0, demand - 1)}}

      {:error, error} ->
        Logger.warn("Hackney Error: #{inspect(error)}")
        http_client.stream_next(ref)
        {:noreply, [], %__MODULE__{state | event: event}}

      _ ->
        http_client.stream_next(ref)
        {:noreply, [], %__MODULE__{state | event: event}}
    end
  end

  def terminate(_reason, %__MODULE__{http_client: http_client, ref: ref}) do
    http_client.stop_async(ref)
  end

  defp process_chunk(chunk, acc) do
    cond do
      chunk == "" ->
        acc

      chunk == ":ok" ->
        acc

      chunk =~ ~r/event:\ .*\ndata:\ / ->
        %{"event" => event, "data" => data} =
          Regex.named_captures(~r/event: (?<event>.*)\ndata: (?<data>.*)/, chunk)

        data =
          data
          |> Jason.decode!(keys: :atoms)

        %Event{event: event, data: data}
        |> struct(data)

      chunk =~ ~r/event: / ->
        %{"event" => event} = Regex.named_captures(~r/event: (?<event>.*)/, chunk)
        %Event{event: event, data: nil}

      chunk =~ ~r/data: / ->
        %{"data" => data} = Regex.named_captures(~r/data: (?<data>.*)/, chunk)

        data =
          data
          |> Jason.decode!(keys: :atoms)

        struct(acc, data)

      chunk =~ ~r/"error":/ ->
        error =
          chunk
          |> Jason.decode!(keys: :atoms)

        {:error, error}

      true ->
        acc
    end
  end
end

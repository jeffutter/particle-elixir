defmodule Particle.Stream.Event do
  @moduledoc false
  defstruct event: nil, data: nil, ttl: nil, published_at: nil, coreid: nil
end

defmodule Particle.Stream do
  require Logger

  alias Experimental.GenStage
  alias Particle.Stream.Event
  alias Particle.Http

  use GenStage

  @moduledoc false
  @base_url "https://api.particle.io/v1/"

  defstruct ref: nil, demand: 0, url: "", event: %Event{}

  defdelegate stream(stages), to: GenStage
  defdelegate stop(stage, reason \\ :normal, timeout \\ :infinity), to: GenStage

  def start_link(url, options \\ []) do
    GenStage.start_link(__MODULE__, url, options)
  end

  def init(url) do
    {:ok, ref} = Http.stream(url, self())
    {:producer, %__MODULE__{ref: ref, url: url}}
  end

  def handle_demand(demand, state) when demand > 0 do
    if state.demand == 0, do: :hackney.stream_next(state.ref)
    {:noreply, [], %__MODULE__{state | demand: state.demand + demand}}
  end

  def handle_info({:hackney_response, ref, {:status, status_code, reason}}, state)  do
    if status_code in 200..299 do
      if state.demand > 0, do: :hackney.stream_next(ref)
      {:noreply, [], %__MODULE__{state | ref: ref}}
    else
      Logger.warn "Hackney Error: #{status_code} - #{inspect reason}"
      :hackney.stream_next(ref)
      {:noreply, [], %__MODULE__{state | ref: ref}}
    end
  end

  def handle_info({:hackney_response, _ref, {:headers, _headers}}, state) do
    :hackney.stream_next(state.ref)
    {:noreply, [], state}
  end

  def handle_info({:hackney_response, _ref, {:error, reason}}, state) do
    Logger.warn "Hackney Error: #{inspect reason}"
    {:stop, reason, state}
  end

  def handle_info({:hackney_response, _ref, :done}, state) do
    Logger.warn "Connection Closed"
    {:stop, "Connection Closed", state}
  end

  def handle_info({:hackney_response, _ref, chunk}, state) when is_binary(chunk) do
    case event = process_chunk(chunk, state.event) do
      %Event{data: d, event: e} when not is_nil(d) and not is_nil(e) ->
        if state.demand > 0, do: :hackney.stream_next(state.ref)
        {:noreply, [event], %__MODULE__{state | event: %Event{}, demand: max(0, state.demand - 1)}}
      {:error, error} ->
        Logger.warn "Hackney Error: #{inspect error}"
        :hackney.stream_next(state.ref)
        {:noreply, [], %__MODULE__{state | event: event}}
      _ ->
        :hackney.stream_next(state.ref)
        {:noreply, [], %__MODULE__{state | event: event}}
    end
  end

  def terminate(_reason, state) do
    :hackney.stop_async(state.ref)
  end

  defp process_chunk(chunk, acc \\ %Event{}) do
    cond do
      chunk == ""    ->
        acc
      chunk == ":ok" ->
        acc
      chunk =~ ~r/event: / ->
        %{"event" => event} = Regex.named_captures(~r/event: (?<event>.*)/, chunk)
        %Event{event: event, data: nil}
      chunk =~ ~r/data: / ->
        %{"data" => data} = Regex.named_captures(~r/data: (?<data>.*)/, chunk)
        data = data
        |> Poison.decode!(keys: :atoms)
        struct(acc, data)
      chunk =~ ~r/"error":/ ->
        error = chunk
        |> Poison.decode!(keys: :atoms)
        {:error, error}
      true ->
        acc
    end
  end
end

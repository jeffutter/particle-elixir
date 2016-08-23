defmodule Particle.Base do
  alias Particle.Error
  alias Particle.Response
  alias Particle.Http
  alias Particle.Stream
  require Logger

  @moduledoc false

  def get(url, struct) do
    url
    |> Http.get
    |> to_response(struct)
  end
  def get(endpoint, url, struct) do
    get("#{endpoint}/#{url}", struct)
  end

  def stream(url) do
    {:ok, stage} = Stream.start_link(url)
    Stream.stream([{stage, [min_demand: 500, max_demand: 1_000]}])
  end
  def stream(endpoint, url) do
    stream("#{endpoint}/#{url}")
  end

  def post(url, params, struct) do
    url
    |> Http.post(params)
    |> to_response(struct)
  end
  def post(endpoint, url, params, struct) do
    post("#{endpoint}/#{url}", params, struct)
  end

  defp to_response({:error, error}, _struct) do
    {:error, Error.new(500, error)}
  end
  defp to_response({:ok, %Response{status_code: 200, body: body}}, s) when is_list(s) do
    res = body
    |> Enum.map(&struct(List.first(s), &1))
    {:ok, res}
  end
  defp to_response({:ok, %Response{status_code: 200, body: body}}, s) do
    {:ok, struct(s, body)}
  end
  defp to_response({:ok, %Response{status_code: status, body: body}}, _struct) do
    {:error, Error.new(status, body)}
  end
  defp to_response({:ok, %Response{status_code: 500}}, _struct) do
    {:error, Error.new(500, "Internal Server Error")}
  end
end

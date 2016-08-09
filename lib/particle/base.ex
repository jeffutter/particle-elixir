defmodule Particle.Base do
  alias Particle.Http
  alias Particle.Stream
  require Logger

  @moduledoc false

  def get(url, struct) do
    url
    |> Http.get
    |> to_response(struct)
  end

  def stream(url) do
    Stream.create_stream(url)
  end

  def post(url, params, struct) do
    url
    |> Http.post({:form, params})
    |> to_response(struct)
  end

  def get(endpoint, id, struct) do
    get("#{endpoint}/#{id}", struct)
  end

  defp to_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, struct) do
     {:ok, Poison.decode!(body, keys: :atoms, as: struct)}
  end

  defp to_response({:ok, %HTTPoison.Response{status_code: 500}}, _struct) do
    {:error, "Internal Server Error", 500}
  end

  defp to_response({:ok, %HTTPoison.Response{status_code: status, body: body}}, _struct) do
    body = try do
      Poison.decode!(body, keys: :atoms, as: Particle.Error)
    rescue
      e in Poison.SyntaxError ->
        Logger.error "Error Decoding Body: " <> inspect(e.message) <> " Body: " <> body
        raise e
      e in RuntimeError ->
        raise e
    end
    {:error, body.error, status}
  end

  defp to_response({:error, %HTTPoison.Error{reason: reason}}, _struct) do
    {:error, reason}
  end
end

defmodule Particle.Response do
  @moduledoc false

  defstruct [:status_code, :headers, :body]

  @type t :: %__MODULE__{
          status_code: status_code,
          headers: headers,
          body: body
        }

  @type status_code :: integer
  @type headers :: list
  @type body :: binary | map

  def new(status_code, headers, body) do
    %__MODULE__{
      status_code: status_code,
      headers: process_headers(headers),
      body: decode_response_body(body)
    }
  end

  defp process_headers(headers) do
    headers
    |> Enum.map(fn {k, v} -> {String.downcase(k), v} end)
  end

  defp decode_response_body(""), do: ""
  defp decode_response_body(" "), do: ""

  defp decode_response_body(body) do
    Jason.decode!(body, keys: :atoms)
  end
end

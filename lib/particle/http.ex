defmodule Particle.Http do
  use HTTPoison.Base

  @moduledoc false
  @url "https://api.particle.io/v1/"

  @spec process_url(binary) :: binary
  defp process_url(endpoint) do
    @url <> endpoint
  end

  defp process_request_headers(headers) when is_map(headers) do
    Enum.into(headers, [authorization_header])
  end
  defp process_request_headers(_headers) do
    Enum.into(%{}, [authorization_header])
  end

  defp process_response_chunk(chunk) do
    chunk
    |> String.replace("\n", "")
  end

  @spec authorization_header() :: {:Authorization, binary}
  defp authorization_header do
    {:Authorization, "Bearer #{Application.get_env(:particle, :particle_key)}"}
  end
end

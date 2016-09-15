defmodule Particle.Http do
  alias Particle.Error
  alias Particle.Stream
  alias Particle.Response

  @moduledoc false
  @base_url "https://api.particle.io/v1/"
  @default_stream_timeout 60_000

  @spec request(atom, binary, any, [{binary, binary}], Keyword.t) :: {:ok, Response.t} | {:error, Error.t}
  def request(method, url, body \\ "", headers \\ [], opts \\ []) do
    url = url |> process_url |> process_params(opts[:params])
    headers = process_request_headers(headers)
    body = encode_request_body(body)

    case :hackney.request(method, url, headers, body, opts) do
      {:ok, 500, _headers, _client} ->
        {:error, Error.new(500, "Internal Server Error")}
      {:ok, status, headers, client} ->
        case :hackney.body(client) do
          {:ok, body} ->
            {:ok, Response.new(status, headers, body)}
          {:error, reason} ->
            {:error, Error.new(500, reason)}
        end
      {:ok, id} ->
        {:ok, id}
      {:error, reason} ->
        {:error, Error.new(500, reason)}
    end
  end

  def get(url) do
    request(:get, url)
  end

  def post(url, params) do
    request(:post, url, params)
  end

  def stream(url, stream_to, timeout \\ @default_stream_timeout) do
    options = [
      {:stream_to, stream_to},
      {:async, :once},
      {:recv_timeout, :infinity}
    ]
    request(:get, url, "", [], options)
  end

  defp process_params(url, nil), do: url
  defp process_params(url, params), do: url <> "?" <> URI.encode_query(params)

  @spec process_url(binary) :: binary
  defp process_url(url) do
    case String.downcase(url) do
      <<"http://"::utf8, _::binary>> -> url
      <<"https://"::utf8, _::binary>> -> url
      _ -> @base_url <> url
    end
  end

  defp encode_request_body(""), do: ""
  defp encode_request_body([]), do: ""
  defp encode_request_body(l) when is_list(l), do: {:form, l}

  defp process_request_headers(headers) when is_map(headers) do
    Enum.into(headers, [authorization_header])
  end
  defp process_request_headers(_headers) do
    Enum.into(%{}, [authorization_header])
  end

  @spec authorization_header() :: {:Authorization, binary}
  defp authorization_header do
    {:Authorization, "Bearer #{Application.get_env(:particle, :particle_key)}"}
  end
end

defmodule Particle.Variables do
  alias Particle.Base
  alias Particle.Device
  alias Particle.Error

  defstruct [:name, :result]
  @type t :: %__MODULE__{name: binary, result: binary}

  @moduledoc """
  This module defines the actions that can be taken on the Variables endpoint.
  """

  @spec get(binary, binary) :: {:ok, any} | Error.t
  def get(device_id, variable_name) do
    Base.get("devices/#{device_id}", variable_name, __MODULE__)
  end

  @spec get_all_with_values(binary) :: {:ok, %{key: Atom}} | Error.t
  def get_all_with_values(device_id) do
    case get_variables(device_id) do
      {:ok, variables} ->
        result = variables
        |> pmap(fn {k,_v} -> {k, get_value(device_id, k)} end)
        |> Enum.into(%{})
        {:ok, result}
      error ->
        error
    end
  end

  @spec get_variables(binary) :: {:ok, map} | Error.t
  defp get_variables(device_id) do
    case Device.get(device_id) do
      {:ok, %Device{connected: false}} ->
        Error.new(503, "Device is offline.")
      {:ok, device} ->
        {:ok, device.variables}
      error ->
        error
    end
  end

  @spec get_value(binary, Atom) :: Number | binary
  defp get_value(device_id, k) do
    case get(device_id, k) do
      {:ok, response} ->
        response.result
      _ ->
        "FAILURE"
    end
  end

  @spec pmap(%{}, (... -> any)) :: map
  defp pmap(collection, function) do
    me = self
    collection
    |> Enum.map(fn (elem) ->
      spawn_link(fn -> (send me, {self, function.(elem)}) end) end)
    |> Enum.map(fn (pid) ->
      receive do
        {^pid, result} -> result
      end end)
  end
end

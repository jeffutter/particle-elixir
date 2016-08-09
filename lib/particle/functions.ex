defmodule Particle.Functions do
  alias Particle.Base

  defstruct [:id, :name, :connected, :return_value]
  @type t :: %__MODULE__{id: binary, name: binary, connected: Boolean, return_value: Integer}
  @type error :: {:error, binary, Integer}
  @type fatal :: {:error, binary}

  @moduledoc """
  This module defines the actions that can be taken on the Functions endpoint.
  """

  @spec post(binary, binary, binary) :: {:ok, any} | error | fatal
  def post(device_id, function_name, argument) do
    Base.post("devices/#{device_id}/#{function_name}", [{:args, argument}], __MODULE__)
  end
end

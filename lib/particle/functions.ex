defmodule Particle.Functions do
  alias Particle.Base

  defstruct [:id, :name, :connected, :return_value]
  @type t :: %__MODULE__{id: binary, name: binary, connected: Boolean, return_value: Integer}

  @endpoint "devices"

  @moduledoc """
  This module defines the actions that can be taken on the Functions endpoint.
  """

  @spec post(binary, binary, binary) :: {:ok, any} | Error.t
  def post(device_id, function_name, argument) do
    Base.post(@endpoint, "#{device_id}/#{function_name}", [{:arg, argument}], __MODULE__)
  end
end

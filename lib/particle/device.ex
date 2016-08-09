defmodule Particle.Device do
  alias Particle.Base

  defstruct [:id, :name, :connected, variables: %{}, functions: []]
  @type t :: %__MODULE__{id: binary, name: binary, connected: Boolean, variables: %{Atom => binary}, functions: [binary]}
  @type error :: {:error, binary, Integer}
  @type fatal :: {:error, binary}

  @endpoint "devices"

  @moduledoc """
  This module defines the actions that can be taken on the Device endpoint.
  """

  @spec get(binary) :: {:ok, t} | error | fatal
  def get(device_id) do
    Base.get(@endpoint, device_id, __MODULE__)
  end

  @spec events(binary) :: Enumerable.t
  def events(device_id) do
    Base.stream("#{@endpoint}/#{device_id}/events")
  end
end

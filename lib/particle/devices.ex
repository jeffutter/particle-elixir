defmodule Particle.Devices do
  alias Particle.Base

  @type t :: [Particle.Device]
  @type error :: {:error, binary, Integer}
  @type fatal :: {:error, binary}

  @endpoint "devices"

  @moduledoc """
  This module defines the actions that can be taken on the Devices endpoint.
  """

  @spec get :: {:ok, t} | error | fatal
  def get do
    Base.get(@endpoint, [%Particle.Device{}])
  end
end

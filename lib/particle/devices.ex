defmodule Particle.Devices do
  alias Particle.Base
  alias Particle.Error

  @type t :: [Particle.Device]

  @endpoint "devices"

  @moduledoc """
  This module defines the actions that can be taken on the Devices endpoint.
  """

  @spec get :: {:ok, t} | Error.t()
  def get do
    Base.get(@endpoint, [%Particle.Device{}])
  end
end

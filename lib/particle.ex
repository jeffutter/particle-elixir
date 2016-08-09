defmodule Particle do
  use Application

  @moduledoc """
  Particle is a client for the Particle Cloud API.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []

    opts = [strategy: :one_for_one, name: Particle.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

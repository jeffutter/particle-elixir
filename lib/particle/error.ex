defmodule Particle.Error do
  defstruct [:error, :info]
  @type t :: %__MODULE__{error: binary, info: binary}

  @moduledoc false
end

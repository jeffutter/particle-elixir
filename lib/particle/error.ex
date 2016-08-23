defmodule Particle.Error do
  @moduledoc false

  defstruct [:reason, :info, :code]
  @type t :: %__MODULE__{
    reason: binary,
    info: binary,
    code: integer
  }

  def new(code, %{error: reason, info: info}) do
    %__MODULE__{
      reason: reason,
      info: info,
      code: code
    }
  end
  def new(code, %{error: reason, ok: false}) do
    %__MODULE__{
      reason: reason,
      code: code
    }
  end
  def new(code, reason) do
    %__MODULE__{
      reason: reason,
      code: code
    }
  end
end

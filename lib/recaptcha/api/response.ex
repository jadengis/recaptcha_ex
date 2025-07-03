defmodule Recaptcha.API.Response do
  @moduledoc """
  Recaptcha API response struct.
  """
  @struct_fields [:success, :score, :action, :challenge_ts, :hostname, :"error-codes"]
  defstruct @struct_fields

  @typedoc """
  The structure of the API Response.
  """
  @type t :: %__MODULE__{
          success: boolean(),
          score: number(),
          action: String.t(),
          challenge_ts: String.t(),
          hostname: String.t(),
          "error-codes": [String.t()]
        }

  @doc """
  Create a new response struct.
  """
  @spec new(map()) :: t()
  def new(data) when is_map(data) do
    init = @struct_fields |> Enum.reduce(%{}, &Map.put(&2, &1, data[Atom.to_string(&1)]))
    struct(__MODULE__, init)
  end
end

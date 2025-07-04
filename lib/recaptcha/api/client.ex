defmodule Recaptcha.API.Client do
  @moduledoc """
  The API client underlying calls to Recaptcha API.
  """
  @enforce_keys [:req, :secret]
  defstruct req: nil, secret: nil

  @typedoc """
  The type of the Recaptcha API client.
  """
  @type t :: %__MODULE__{
          req: Req.Request.t(),
          secret: String.t()
        }
end

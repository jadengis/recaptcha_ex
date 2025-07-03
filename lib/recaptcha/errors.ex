defmodule Recaptcha.APIError do
  defexception [:message]

  def exception(opts) do
    error = Keyword.fetch!(opts, :error)
    msg = "failed to call recaptcha API, error: #{inspect(error)}"
    %__MODULE__{message: msg}
  end
end

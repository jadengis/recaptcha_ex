defmodule Recaptcha.APIError do
  defexception [:message]

  def exception(opts) do
    error = Keyword.fetch!(opts, :error)
    msg = "failed to call recaptcha API, error: #{inspect(error)}"
    %__MODULE__{message: msg}
  end
end

defmodule Recaptcha.VerificationError do
  defexception [:message]

  def exception(opts) do
    error_codes = Keyword.fetch!(opts, :error_codes)
    msg = "recaptcha verification failed, error codes: #{inspect(error_codes)}"
    %__MODULE__{message: msg}
  end
end

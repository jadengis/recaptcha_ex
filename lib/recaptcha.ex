defmodule Recaptcha do
  @moduledoc """
  Documentation for `Recaptcha`.
  """

  @typedoc """
  The structure of a recaptcha API response.
  """
  @type t :: __MODULE__.API.Response.t()

  @doc """
  Fetch the recaptcha host from the application configuration.
  """
  def host(), do: Application.get_env(:recaptcha, :host, "https://www.google.com")

  @doc """
  Fetch the recaptcha site key from the application configuration.
  """
  def site_key(), do: Application.get_env(:recaptcha, :site_key)

  @doc """
  Fetch the recaptcha secret from the application configuration.
  """
  def secret(), do: Application.get_env(:recaptcha, :secret)
end

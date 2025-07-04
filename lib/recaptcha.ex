defmodule Recaptcha do
  @moduledoc """
  Documentation for `Recaptcha`.
  """

  @typedoc """
  The structure of a recaptcha API response.
  """
  @type t :: __MODULE__.API.Response.t()

  @doc """
  Fetch the recaptcha base_url from the application configuration.
  """
  def base_url(), do: Application.get_env(:recaptcha, :base_url, "https://www.google.com")

  @doc """
  Fetch the recaptcha site key from the application configuration.
  """
  def site_key(), do: Application.get_env(:recaptcha, :site_key)

  @doc """
  Fetch the recaptcha secret from the application configuration.
  """
  def secret(), do: Application.get_env(:recaptcha, :secret)
end

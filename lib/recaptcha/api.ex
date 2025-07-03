defmodule Recaptcha.API do
  @moduledoc """
  Recaptcha API client.
  """
  alias Recaptcha.API.Response

  @verify_path "/recaptcha/api/siteverify"
  @headers [
    {"content-type", "application/x-www-form-urlencoded"},
    {"accept", "application/json"}
  ]

  @doc """
  Perform the recaptcha verification request against the Google server.
  """
  @spec verify(String.t()) :: {:ok, Response.t()} | {:error, map()}
  def verify(token) do
    req =
      Req.new(
        url: verify_url(),
        headers: @headers,
        form: [secret: secret(), response: token]
      )

    case Req.post(req) do
      {:ok, %Req.Response{status: 200, body: data}} -> {:ok, Response.new(data)}
      {:ok, %Req.Response{status: _, body: data}} -> {:error, data}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec secret() :: String.t()
  defp secret, do: Application.get_env(:recaptcha, :secret)

  @spec verify_url() :: String.t()
  defp verify_url,
    do:
      "#{Recaptcha.host()}#{@verify_path}"
      |> URI.new!()
      |> URI.to_string()
end

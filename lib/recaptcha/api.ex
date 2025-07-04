defmodule Recaptcha.API do
  @moduledoc """
  Recaptcha API client.
  """
  alias Recaptcha.API.Client
  alias Recaptcha.API.Response

  @verify_url "/recaptcha/api/siteverify"
  @headers [
    {"content-type", "application/x-www-form-urlencoded"},
    {"accept", "application/json"}
  ]
  @opts_schema [
    base_url: [type: :string, required: false],
    secret: [type: :string, required: true]
  ]

  @doc """
  Create a new GoogleAI client with the given `opts`.

  ## Options

  #{NimbleOptions.docs(@opts_schema)}
  ## Examples

    iex> Recaptcha.client(secret: "asdfasdf")
    %Recaptcha.Client{
      req: Req.new(
        base_url: "https://www.google.com", 
      ),
      secret: "asdfasdf"
    }

    iex> Recaptcha.client(base_url: "https://example.com", secret: "asdfasdf")
    %Recaptcha.Client{
      req: Req.new(
        base_url: "https://example.com", 
      ),
      secret: "asdfasdf"
    }

  """
  @spec client(opts :: Keyword.t()) :: Client.t()
  def client(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:base_url, base_url())
      |> Keyword.put_new(:secret, secret())
      |> NimbleOptions.validate!(@opts_schema)

    req =
      Req.new(
        base_url: opts[:base_url],
        headers: @headers
      )

    %Client{req: req, secret: opts[:secret]}
  end

  @doc """
  Perform the recaptcha verification request against the Google server.
  """
  @spec verify(Client.t(), String.t()) :: {:ok, Response.t()} | {:error, map()}
  def verify(%Client{req: req, secret: secret} \\ client(), token) do
    req =
      req
      |> Req.merge(
        url: @verify_url,
        form: [secret: secret, response: token]
      )

    case Req.post(req) do
      {:ok, %Req.Response{status: 200, body: data}} -> {:ok, Response.new(data)}
      {:ok, %Req.Response{status: _, body: data}} -> {:error, data}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec secret() :: String.t()
  defp secret, do: Recaptcha.secret()

  @spec base_url() :: String.t()
  defp base_url, do: Recaptcha.base_url()
end

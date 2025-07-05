defmodule Recaptcha.API do
  @moduledoc """
  HTTP client for Google reCAPTCHA verification API.

  This module provides the core functionality for communicating with Google's
  reCAPTCHA verification service. It handles the creation of HTTP clients and
  verification of reCAPTCHA response tokens.

  ## Overview

  The `Recaptcha.API` module serves as the primary interface for:
  - Creating configured HTTP clients for reCAPTCHA API requests
  - Verifying reCAPTCHA response tokens against Google's servers
  - Handling API responses and errors

  ## Basic Usage

      # Create a client with default configuration
      client = Recaptcha.API.client()

      # Create a client with custom configuration
      client = Recaptcha.API.client(
        base_url: "https://www.google.com",
        secret: "your-secret-key"
      )

      # Verify a reCAPTCHA token
      case Recaptcha.API.verify(client, token) do
        {:ok, %Recaptcha.API.Response{success: true}} ->
          # Token is valid
        {:ok, %Recaptcha.API.Response{success: false}} ->
          # Token is invalid
        {:error, reason} ->
          # Network or API error
      end

  ## Configuration

  The module uses application configuration for default values:

      config :recaptcha,
        host: "https://www.google.com",
        site_key: "your-site-key",
        secret: "your-secret-key"

  Configuration can be overridden when creating a client by passing options
  to `client/1`.
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
  Create a new Recaptcha client with the given `opts`.

  ## Options

  #{NimbleOptions.docs(@opts_schema)}
  ## Examples

    iex> Recaptcha.API.client(secret: "asdfasdf")
    %Recaptcha.API.Client{
      req: Req.new(
        base_url: "https://www.google.com", 
        headers: %{"accept" => ["application/json"], "content-type" => ["application/x-www-form-urlencoded"]}
      ),
      secret: "asdfasdf"
    }

    iex> Recaptcha.API.client(base_url: "https://example.com", secret: "asdfasdf")
    %Recaptcha.API.Client{
      req: Req.new(
        base_url: "https://example.com", 
        headers: %{"accept" => ["application/json"], "content-type" => ["application/x-www-form-urlencoded"]}
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
  Verifies a reCAPTCHA response token against Google's verification API.

  This function sends a POST request to Google's reCAPTCHA verification endpoint
  with the provided token and the client's secret key. It returns a structured
  response indicating whether the verification was successful.

  ## Parameters

  - `client` - A `Recaptcha.API.Client` struct containing the HTTP client and secret key.
    If not provided, a default client will be created using `client/1`.
  - `token` - The reCAPTCHA response token received from the client-side reCAPTCHA widget.

  ## Returns

  - `{:ok, %Recaptcha.API.Response{}}` - When the HTTP request succeeds (status 200).
    The response struct contains verification details including success status, score,
    action, and any error codes.
  - `{:error, map()}` - When the HTTP request fails (non-200 status) or encounters
    a network error. Returns the raw response body or error reason.

  ## Examples

      # Successful verification
      iex> client = Recaptcha.API.client(secret: "valid_secret")
      iex> # Note: This would require a valid token and network access
      iex> # {:ok, %Recaptcha.API.Response{success: true, score: 0.9}} = Recaptcha.API.verify(client, "valid_token")

      # Using default client
      iex> # Recaptcha.API.verify("token_string")

      # Failed verification returns error tuple
      iex> # {:error, %{"success" => false, "error-codes" => ["invalid-input-response"]}}

  ## Response

  A successful response contains:
  - `success` - Boolean indicating if the token is valid
  - `score` - Float between 0.0 and 1.0 indicating likelihood of being human (v3 only)
  - `action` - String identifying the action name (v3 only)
  - `challenge_ts` - ISO timestamp of the challenge
  - `hostname` - Hostname of the site where the reCAPTCHA was solved
  - `error-codes` - List of error codes if verification failed

  ## Error Codes

  Common error codes include:
  - `"missing-input-secret"` - Secret parameter is missing
  - `"invalid-input-secret"` - Secret parameter is invalid or malformed
  - `"missing-input-response"` - Response parameter is missing
  - `"invalid-input-response"` - Response parameter is invalid or malformed
  - `"bad-request"` - Request is invalid or malformed
  - `"timeout-or-duplicate"` - Response has already been used or is too old
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

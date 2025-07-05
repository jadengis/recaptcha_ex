if Code.ensure_loaded?(Plug) do
  defmodule Recaptcha.Verifier do
    @moduledoc """
    Plug middleware for automatic reCAPTCHA v3 verification.

    This module provides a Plug that automatically verifies reCAPTCHA tokens
    in incoming requests. It integrates seamlessly with Phoenix applications
    and other Plug-based web frameworks to provide server-side reCAPTCHA
    verification without manual intervention.

    ## Usage

    Add the plug to your router, controller, or pipeline:

    ### Router Pipeline

        pipeline :protected do
          plug :accepts, ["html"]
          plug :fetch_session
          plug :protect_from_forgery
          plug Recaptcha.Verifier
        end

    ### Controller

        defmodule MyAppWeb.ContactController do
          use MyAppWeb, :controller

          plug Recaptcha.Verifier

          def create(%{assigns: %{recaptcha_response: recaptcha}} = conn, params) do
            # Token has been verified, access the response
            %{score: score} = recaptcha
            # Process the request...
          end
        end

    ## Configuration

    The plug can be configured with options:

        plug Recaptcha.Verifier, client: custom_client

    Available options:
    - `:client` - Custom API client (defaults to `Recaptcha.API.client()`)

    ## Request Processing

    The plug follows this flow:

    1. **Token Extraction**: Looks for `g-recaptcha-response` parameter
    2. **Verification**: Calls Google's reCAPTCHA API with the token
    3. **Success Handling**: Attaches response to `conn.assigns.recaptcha_response`
    4. **Error Handling**: Raises appropriate exceptions for failures
    5. **Pass Through**: Requests without tokens are passed through unchanged

    ## Error Handling

    The plug raises structured exceptions for different failure scenarios:

    - `Recaptcha.VerificationError` - When reCAPTCHA verification fails
    - `Recaptcha.APIError` - When the API request encounters an error

    These exceptions should be handled by your application's error handling
    middleware or try/catch blocks.

    """
    alias Recaptcha.API
    alias Recaptcha.API.Response
    alias Recaptcha.APIError
    alias Recaptcha.VerificationError

    @behaviour Plug

    @recaptcha_form_field "g-recaptcha-response"

    @impl Plug
    def init(opts), do: opts |> Keyword.put_new(:client, Recaptcha.API.client())

    @impl Plug
    def call(%{params: %{@recaptcha_form_field => token}} = conn, opts) do
      opts[:client] |> API.verify(token) |> handle_response(conn)
    end

    def call(conn, _opts), do: conn

    defp handle_response({:ok, %Response{success: true, score: _score} = response}, conn) do
      # Attach the response to the conn so downstream handlers can use the score.
      Plug.Conn.assign(conn, :recaptcha_response, response)
    end

    defp handle_response({:ok, %Response{success: false, "error-codes": error_codes}}, _conn) do
      raise VerificationError, error_codes: error_codes
    end

    defp handle_response({:error, reason}, _conn) do
      raise APIError, error: reason
    end
  end
end

if Code.ensure_loaded?(Plug) do
  defmodule Recaptcha.Verifier do
    @moduledoc """
    A plug for verifying a recaptcha v3 request.
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

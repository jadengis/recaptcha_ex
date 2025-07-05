defmodule Recaptcha.VerifierTest do
  use ExUnit.Case, async: true
  import Plug.Test

  alias Recaptcha.Verifier
  alias Recaptcha.APIError
  alias Recaptcha.VerificationError

  @secret "secret"
  @token "token"

  setup do
    bypass = Bypass.open()

    client =
      Recaptcha.API.client(
        base_url: endpoint_url(bypass.port),
        secret: @secret
      )

    %{bypass: bypass, client: client}
  end

  describe "call/2" do
    test "passes through request when no recaptcha token is present" do
      conn = conn(:post, "/", %{})
      result = Verifier.call(conn, [])
      assert result == conn
    end

    test "attaches successful recaptcha response to conn", %{bypass: bypass, client: client} do
      Bypass.expect_once(bypass, "POST", "/recaptcha/api/siteverify", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, successful_response())
      end)

      conn = conn(:post, "/", %{"g-recaptcha-response" => @token})
      result = Verifier.call(conn, client: client)

      assert result.assigns.recaptcha_response.success == true
      assert result.assigns.recaptcha_response.score == 0.9
      assert result.assigns.recaptcha_response.action == "contact"
      assert result.assigns.recaptcha_response.hostname == "example.com"
    end

    test "raises VerificationError when API returns success=false with error codes", %{
      bypass: bypass,
      client: client
    } do
      Bypass.expect_once(bypass, "POST", "/recaptcha/api/siteverify", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, failed_verification_response())
      end)

      conn = conn(:post, "/", %{"g-recaptcha-response" => @token})

      assert_raise VerificationError,
                   "recaptcha verification failed, error codes: [\"invalid-input-response\"]",
                   fn ->
                     Verifier.call(conn, client: client)
                   end
    end

    test "raises VerificationError with multiple error codes", %{bypass: bypass, client: client} do
      Bypass.expect_once(bypass, "POST", "/recaptcha/api/siteverify", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, multiple_errors_response())
      end)

      conn = conn(:post, "/", %{"g-recaptcha-response" => @token})

      assert_raise VerificationError,
                   ~r/recaptcha verification failed, error codes: \[\"invalid-input-response\", \"timeout-or-duplicate\"\]/,
                   fn ->
                     Verifier.call(conn, client: client)
                   end
    end

    test "raises APIError when API returns non-200 status code", %{bypass: bypass, client: client} do
      Bypass.expect_once(bypass, "POST", "/recaptcha/api/siteverify", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(400, failed_verification_response())
      end)

      conn = conn(:post, "/", %{"g-recaptcha-response" => @token})

      assert_raise APIError, ~r/failed to call recaptcha API/, fn ->
        Verifier.call(conn, client: client)
      end
    end

    test "raises APIError when API returns 500 error", %{bypass: bypass, client: client} do
      Bypass.expect_once(bypass, "POST", "/recaptcha/api/siteverify", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, ~s<{"error": "internal server error"}>)
      end)

      conn = conn(:post, "/", %{"g-recaptcha-response" => @token})

      assert_raise APIError, ~r/failed to call recaptcha API/, fn ->
        Verifier.call(conn, client: client)
      end
    end

    test "raises APIError when network request fails", %{bypass: bypass, client: client} do
      Bypass.down(bypass)

      conn = conn(:post, "/", %{"g-recaptcha-response" => @token})

      assert_raise APIError, ~r/failed to call recaptcha API/, fn ->
        Verifier.call(conn, client: client)
      end
    end

    test "handles empty error codes array", %{bypass: bypass, client: client} do
      Bypass.expect_once(bypass, "POST", "/recaptcha/api/siteverify", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, failed_verification_empty_errors_response())
      end)

      conn = conn(:post, "/", %{"g-recaptcha-response" => @token})

      assert_raise VerificationError, "recaptcha verification failed, error codes: []", fn ->
        Verifier.call(conn, client: client)
      end
    end
  end

  describe "init/1" do
    test "returns the includes a client" do
      opts = [some: :option]
      assert Verifier.init(opts) == [client: Recaptcha.API.client(), some: :option]
    end
  end

  # Helper functions
  defp endpoint_url(port), do: "http://localhost:#{port}"

  defp successful_response, do: ~s<{
  "success": true,
  "score": 0.9,
  "action": "contact",
  "challenge_ts": "2019-04-03T18:22:41Z",
  "hostname": "example.com",
  "error-codes": []
}>

  defp failed_verification_response, do: ~s<{
  "success": false,
  "score": 0.9,
  "action": "contact",
  "challenge_ts": "2019-04-03T18:22:41Z",
  "hostname": "example.com",
  "error-codes": ["invalid-input-response"]
}>

  defp multiple_errors_response, do: ~s<{
  "success": false,
  "score": 0.9,
  "action": "contact",
  "challenge_ts": "2019-04-03T18:22:41Z",
  "hostname": "example.com",
  "error-codes": ["invalid-input-response", "timeout-or-duplicate"]
}>

  defp failed_verification_empty_errors_response, do: ~s<{
  "success": false,
  "score": 0.1,
  "action": "contact",
  "challenge_ts": "2019-04-03T18:22:41Z",
  "hostname": "example.com",
  "error-codes": []
}>
end

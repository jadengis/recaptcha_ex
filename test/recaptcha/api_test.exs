defmodule Recaptcha.APITest do
  use ExUnit.Case, async: true

  alias Recaptcha.API
  alias Recaptcha.API.Response

  @secret "secret"
  @token "token"

  setup do
    bypass = Bypass.open()
    put_application_env_for_test(:recaptcha, :host, endpoint_url(bypass.port))
    put_application_env_for_test(:recaptcha, :secret, @secret)
    %{bypass: bypass}
  end

  describe "verify/1" do
    test "performs a POST request using the supplied token", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/recaptcha/api/siteverify", fn conn ->
        conn = parse_body(conn)
        assert conn.params["secret"] == @secret
        assert conn.params["response"] == @token

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response())
      end)

      assert {:ok,
              %Response{
                success: true,
                score: 0.9,
                action: "contact",
                hostname: "example.com",
                "error-codes": []
              }} = API.verify(@token)
    end

    test "returns an :ok tuple with a 200 code and error response data", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/recaptcha/api/siteverify", fn conn ->
        conn = parse_body(conn)
        assert conn.params["secret"] == @secret
        assert conn.params["response"] == @token

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response_with_error())
      end)

      assert {:ok,
              %Response{
                success: false,
                score: 0.9,
                action: "contact",
                hostname: "example.com",
                "error-codes": ["invalid-input-response"]
              }} = API.verify(@token)
    end

    test "returns an :error tuple with a non-200 code and error response data", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/recaptcha/api/siteverify", fn conn ->
        conn = parse_body(conn)
        assert conn.params["secret"] == @secret
        assert conn.params["response"] == @token

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(400, response_with_error())
      end)

      assert {:error,
              %{
                "success" => false,
                "score" => 0.9,
                "action" => "contact",
                "hostname" => "example.com",
                "error-codes" => ["invalid-input-response"]
              }} = API.verify(@token)
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"

  defp put_application_env_for_test(app, key, value) do
    previous_value = Application.get_env(app, key)
    Application.put_env(app, key, value)
    on_exit(fn -> Application.put_env(app, key, previous_value) end)
  end

  defp parse_body(conn) do
    opts =
      Plug.Parsers.init(
        parsers: [:urlencoded, :multipart],
        pass: ["*/*"]
      )

    Plug.Parsers.call(conn, opts)
  end

  defp response, do: ~s<{
  "success": true,
  "score": 0.9,
  "action": "contact",
  "challenge_ts": "2019-04-03T18:22:41Z",
  "hostname": "example.com",
  "error-codes": []
}>

  defp response_with_error, do: ~s<{
  "success": false,
  "score": 0.9,
  "action": "contact",
  "challenge_ts": "2019-04-03T18:22:41Z",
  "hostname": "example.com",
  "error-codes": ["invalid-input-response"]
}>
end

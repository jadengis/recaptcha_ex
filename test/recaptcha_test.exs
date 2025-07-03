defmodule RecaptchaTest do
  use ExUnit.Case, async: true

  describe "host/0" do
    test "https://www.google.com is the default host" do
      assert Recaptcha.host() == "https://www.google.com"
    end
  end

  describe "site_key/0" do
    setup do
      put_application_env_for_test(:recaptcha, :site_key, "test-site-key")
    end

    test "respects the configured site_key" do
      assert Recaptcha.site_key() == "test-site-key"
    end
  end

  describe "secret/0" do
    setup do
      put_application_env_for_test(:recaptcha, :secret, "test-secret")
    end

    test "respects the configured secret" do
      assert Recaptcha.secret() == "test-secret"
    end
  end

  defp put_application_env_for_test(app, key, value) do
    previous_value = Application.get_env(app, key)
    Application.put_env(app, key, value)
    on_exit(fn -> Application.put_env(app, key, previous_value) end)
  end
end

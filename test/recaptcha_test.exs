defmodule RecaptchaTest do
  use ExUnit.Case, async: true

  describe "base_url/0" do
    test "https://www.google.com is the default base_url" do
      assert Recaptcha.base_url() == "https://www.google.com"
    end
  end

  describe "site_key/0" do
    test "respects the configured site_key" do
      assert Recaptcha.site_key() == "test-site-key"
    end
  end

  describe "secret/0" do
    test "respects the configured secret" do
      assert Recaptcha.secret() == "test-secret"
    end
  end
end

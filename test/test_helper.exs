ExUnit.start()

Application.put_env(:recaptcha, :site_key, "test-site-key")
Application.put_env(:recaptcha, :secret, "test-secret")

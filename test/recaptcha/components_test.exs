defmodule Recaptcha.ComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import Recaptcha.Components

  setup do
    Application.put_env(:recaptcha, :site_key, "abcdefg")
    on_exit(fn -> Application.put_env(:recaptcha, :site_key, nil) end)
  end

  test "recaptcha/1 renders correctly" do
    assigns = %{}

    assert {:ok, html} =
             rendered_to_string(~H"""
             <.recaptcha :let={recaptcha} form_id="form_id" action="login">
              <button id="submit_button" {recaptcha}>Submit</button>
             </.recaptcha>
             """)
             |> Floki.parse_fragment()

    assert Floki.find(html, "button[data-sitekey='abcdefg']") |> Floki.text() == "Submit"
    assert Floki.find(html, "button[data-action='login']") |> Floki.text() == "Submit"
    assert Floki.find(html, "button[data-callback='onFormIdSubmit']") |> Floki.text() == "Submit"

    # =~ "function onFormIdSubmit()"
    assert script = Floki.find(html, "script") |> Floki.text(js: true)
    assert script =~ "function onFormIdSubmit()"
    assert script =~ "document.getElementById(\"form_id\")"
  end
end

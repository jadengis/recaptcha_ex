if Code.ensure_loaded?(Phoenix.Component) do
  defmodule Recaptcha.Components do
    @moduledoc """
    Phoenix components for Google reCAPTCHA v3 integration.

    This module provides Phoenix components that simplify the integration of
    Google reCAPTCHA v3 into Phoenix applications. It handles the client-side
    JavaScript generation and provides a clean interface for embedding reCAPTCHA
    functionality into forms and other interactive elements.

    ## Usage

    The primary component is `recaptcha/1`, which wraps any content that should
    trigger reCAPTCHA verification when clicked (typically submit buttons).

        <.form for={@form} id="contact-form" phx-submit="submit">
          <.input field={@form[:name]} label="Name" />
          <.input field={@form[:email]} label="Email" />
          
          <.recaptcha :let={recaptcha} form_id="contact-form" action="contact">
            <button type="submit" 
                    class="g-recaptcha"
                    {recaptcha} >
              Submit
            </button>
          </.recaptcha>
        </.form>

    ## Configuration

    The component automatically uses the site key from application configuration:

        config :recaptcha,
          site_key: "your-site-key-here"

    ## JavaScript Requirements

    This component requires the Google reCAPTCHA v3 JavaScript library to be loaded
    in your application. Add this to your layout template:

        <script src="https://www.google.com/recaptcha/api.js?render={site_key}"></script>

    ## Security Considerations

    - Always verify reCAPTCHA tokens on the server side using `Recaptcha.API.verify/2`
    - Use meaningful action names to distinguish different contexts
    - Ensure the site key is properly configured and matches your domain
    """
    use Phoenix.Component

    @doc """
    Renders a reCAPTCHA widget that wraps interactive content.

    This component generates the necessary JavaScript callback function and provides
    data attributes for Google reCAPTCHA v3 integration. It wraps any content
    (typically buttons) that should trigger reCAPTCHA verification when clicked.

    ## Attributes

    - `form_id` (required) - The HTML ID of the form to validate and submit.
      This must match the `id` attribute of your form element.
    - `action` (required) - The reCAPTCHA action name for this context.
      Should be descriptive (e.g., "login", "contact", "signup").

    ## Slots

    - `inner_block` (required) - The content to render inside the widget.
      This is typically a submit button or other interactive element.

    ## Data Attributes

    The component passes the following data attributes to the inner block:
    - `data-sitekey` - The reCAPTCHA site key from application configuration
    - `data-action` - The action name provided to the component
    - `data-callback` - The generated JavaScript callback function name

    ## Examples

        <.form for={@form} id="contact-form" phx-submit="submit">
          <.input field={@form[:email]} label="Email" />
          <.recaptcha :let={recaptcha} form_id="contact-form" action="contact">
            <button type="submit" class="g-recaptcha" {recaptcha} >
              Send Message
            </button>
          </.recaptcha>
        </.form>
    """
    attr :form_id, :string, required: true
    attr :action, :string, required: true
    slot :inner_block, required: true

    def recaptcha(assigns) do
      ~H"""
      <script>
        function <%= callback(@form_id) %>() {
        const form = document.getElementById("<%= @form_id %>")
          if(form.reportValidity()) {
            form.submit()
          }
        }
      </script>
      {render_slot(@inner_block, %{
        "data-sitekey" => Recaptcha.site_key(),
        "data-action" => @action,
        "data-callback" => callback(@form_id)
      })}
      """
    end

    @spec callback(String.t()) :: String.t()
    defp callback(form_id), do: "on#{Macro.camelize(form_id)}Submit"
  end
end

if Code.ensure_loaded?(Phoenix.Component) do
  defmodule Recaptcha.Components do
    @moduledoc """
    Components for implementing Recaptcha
    """
    use Phoenix.Component

    @doc """
    Render a recaptcha widget.

    Automatically injects the JavaScript required to handle button clicks.
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

    defp callback(form_id), do: "on#{Macro.camelize(form_id)}Submit"
  end
end

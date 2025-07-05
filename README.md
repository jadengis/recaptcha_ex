# Recaptcha

A modern Elixir library for Google reCAPTCHA v3 integration with Phoenix applications.

[![Hex.pm](https://img.shields.io/hexpm/v/recaptcha.svg)](https://hex.pm/packages/recaptcha)
[![Documentation](https://img.shields.io/badge/documentation-hexdocs-blue.svg)](https://hexdocs.pm/recaptcha)

## Features

- **Complete reCAPTCHA v3 support** - Full integration with Google's latest reCAPTCHA API
- **Phoenix components** - Ready-to-use UI components for seamless integration
- **Plug middleware** - Automatic server-side verification with structured error handling
- **Flexible API client** - Low-level HTTP client for custom verification workflows
- **Optional dependencies** - Works with or without Phoenix/Plug for maximum flexibility
- **Comprehensive documentation** - Detailed guides and examples for all use cases

## Installation

Add `recaptcha` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:recaptcha, "~> 0.1.0"}
  ]
end
```

## Quick Start

### 1. Get reCAPTCHA Keys

1. Visit the [Google reCAPTCHA Admin Console](https://www.google.com/recaptcha/admin)
2. Create a new site with reCAPTCHA v3
3. Get your site key and secret key

### 2. Configure Your Application

Add your reCAPTCHA keys to your application configuration:

```elixir
# config/config.exs
config :recaptcha,
  site_key: "your-site-key-here",
  secret: "your-secret-key-here"
```

### 3. Add JavaScript to Your Layout

Include the reCAPTCHA JavaScript library in your layout template:

```html
<!-- lib/my_app_web/components/layouts/app.html.heex -->
<script src="https://www.google.com/recaptcha/api.js?render=<%= Recaptcha.site_key() %>"></script>
```

### 4. Use in Your Phoenix Application

#### With Phoenix Components

```elixir
<.form for={@form} id="contact-form" phx-submit="submit">
  <.input field={@form[:email]} label="Email" />
  <.input field={@form[:message]} label="Message" />
  
  <.recaptcha form_id="contact-form" action="contact">
    <:inner_block :let={recaptcha}>
      <button type="submit" class="g-recaptcha" {recaptcha}>
        Send Message
      </button>
    </:inner_block>
  </.recaptcha>
</.form>
```

#### With Plug Middleware

```elixir
# In your router or controller
plug Recaptcha.Verifier when action in [:create]

def create(%{assigns: %{recaptcha_response: response}} = conn, params) do
  # Token has been verified automatically
  %{score: score, action: action} = response
  
  if score >= 0.5 do
    # Process the request
  else
    # Handle low score
  end
end
```

#### Manual Verification

```elixir
case Recaptcha.API.verify(token) do
  {:ok, %{success: true, score: score}} when score >= 0.5 ->
    # Verification successful
  {:ok, %{success: false, "error-codes": errors}} ->
    # Verification failed
  {:error, reason} ->
    # Network or API error
end
```

## Usage Examples

### Basic Form with Validation

```elixir
defmodule MyAppWeb.ContactController do
  use MyAppWeb, :controller
  
  plug Recaptcha.Verifier when action in [:create]
  
  def new(conn, _params) do
    changeset = Contact.changeset(%Contact{}, %{})
    render(conn, "new.html", changeset: changeset)
  end
  
  def create(%{assigns: %{recaptcha_response: recaptcha}} = conn, %{"contact" => params}) do
    if recaptcha.score >= 0.5 do
      case Contacts.create_contact(params) do
        {:ok, contact} ->
          redirect(conn, to: Routes.contact_path(conn, :show, contact))
        {:error, changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "reCAPTCHA verification failed")
      |> redirect(to: Routes.contact_path(conn, :new))
    end
  end
end
```

### Custom API Client

```elixir
# Create a custom client with different settings
client = Recaptcha.API.client(
  base_url: "https://recaptcha.net",  # Alternative endpoint
  secret: "custom-secret"
)

# Use the custom client
case Recaptcha.API.verify(client, token) do
  {:ok, response} -> # Handle response
  {:error, reason} -> # Handle error
end
```

## Configuration Options

```elixir
config :recaptcha,
  # Google reCAPTCHA API endpoint (default: "https://www.google.com")
  base_url: "https://www.google.com",
  
  # Your reCAPTCHA site key (public key)
  site_key: "your-site-key",
  
  # Your reCAPTCHA secret key (private key)
  secret: "your-secret-key"
```

## Security Best Practices

1. **Always verify server-side** - Never trust client-side validation alone
2. **Use appropriate score thresholds** - Typically 0.5 or higher for human users
3. **Implement rate limiting** - Protect your verification endpoints
4. **Monitor verification patterns** - Log and analyze failed verifications
5. **Secure your secret key** - Never expose it in client-side code
6. **Use meaningful actions** - Help distinguish different verification contexts

## API Reference

### Core Modules

- `Recaptcha` - Main configuration module
- `Recaptcha.API` - HTTP client for Google's reCAPTCHA API
- `Recaptcha.API.Response` - Response data structure
- `Recaptcha.Components` - Phoenix LiveView components (optional)
- `Recaptcha.Verifier` - Plug middleware for automatic verification (optional)

### Response Structure

```elixir
%Recaptcha.API.Response{
  success: true,           # Boolean - verification success
  score: 0.9,             # Float - human likelihood (0.0-1.0)
  action: "contact",      # String - action identifier
  challenge_ts: "...",    # String - ISO timestamp
  hostname: "example.com", # String - verified hostname
  "error-codes": []       # List - error codes if failed
}
```

## Testing

```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run code analysis
mix credo --strict

# Run static analysis
mix dialyzer
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


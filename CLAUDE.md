# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Elixir library for Google reCAPTCHA v3 integration with Phoenix applications. It provides API verification, Phoenix components, and Plug-based middleware for handling reCAPTCHA requests.

## Common Commands

### Development and Testing
- `mix test` - Run all tests
- `mix test test/path/to/specific_test.exs` - Run a specific test file
- `mix credo` - Run code analysis and style checks
- `mix dialyzer` - Run static type analysis
- `mix deps.get` - Install dependencies
- `mix compile` - Compile the project

### Documentation
- `mix docs` - Generate documentation with ExDoc
- `mix hex.docs` - Generate and publish documentation to HexDocs

### Quality Assurance
Always run these commands before committing:
- `mix test` - Ensure all tests pass
- `mix credo --strict` - Check code style and quality
- `mix dialyzer` - Verify type specifications

## Code Architecture

### Core Modules
- `Recaptcha` - Main module providing configuration helpers (host, site_key, secret)
- `Recaptcha.API` - HTTP client for Google's reCAPTCHA verification endpoint
- `Recaptcha.API.Response` - Struct representing API responses with success, score, action, etc.
- `Recaptcha.Verifier` - Plug middleware for automatic request verification
- `Recaptcha.Components` - Phoenix LiveView components for frontend integration
- `Recaptcha.APIError` - Custom exception for API failures

### Key Dependencies
- `req` - HTTP client for API requests
- `plug` - Web server interface (optional dependency)
- `phoenix_live_view` - UI components (optional dependency)

### Configuration
The library expects these application configuration keys:
- `:recaptcha, :host` - reCAPTCHA API host (defaults to "https://www.google.com")
- `:recaptcha, :site_key` - Public site key from Google
- `:recaptcha, :secret` - Private secret key from Google

### Architecture Pattern
The library follows a layered architecture:
1. **API Layer** (`Recaptcha.API`) - Handles HTTP communication with Google
2. **Data Layer** (`Recaptcha.API.Response`) - Structures API responses
3. **Middleware Layer** (`Recaptcha.Verifier`) - Plug-based request processing
4. **UI Layer** (`Recaptcha.Components`) - Phoenix component integration
5. **Configuration Layer** (`Recaptcha`) - Application configuration access

The code uses conditional compilation (`Code.ensure_loaded?`) to make Phoenix and Plug dependencies optional, allowing the library to work in different environments.
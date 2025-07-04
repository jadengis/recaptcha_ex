defmodule Recaptcha.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Community maintained Recaptcha v3 library for Elixir and Phoenix"
  @source_url "https://github.com/jadengis/recaptcha_ex/"

  def project do
    [
      app: :recaptcha,
      version: @version,
      elixir: "~> 1.13",
      exlirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.4"},
      {:nimble_options, "~> 1.0"},
      {:plug, "~> 1.14", optional: true},
      {:phoenix_live_view, ">= 0.0.0", optional: true},
      {:bypass, "~> 2.1", only: :test},
      {:floki, ">= 0.30.0", only: :test},
      {:html5ever, ">= 0.14.0", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      description: @description,
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end
end

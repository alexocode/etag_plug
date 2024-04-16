defmodule ETagPlug.MixProject do
  use Mix.Project

  @version "version" |> File.read!() |> String.trim()
  @repo "https://github.com/alexocode/etag_plug"

  def project do
    [
      app: :etag_plug,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls],

      # Docs
      name: "ETag Plug",
      source_url: @repo,
      homepage_url: @repo,

      # Hex
      description: description(),
      package: package(),
      version: @version
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.0"},

      # Docs
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},

      # Test
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  def description do
    "A simple to use plug for shallow ETags"
  end

  def package do
    [
      files: ["lib", "mix.exs", "LICENSE*", "README*", "version"],
      licenses: ["MIT"],
      links: %{
        "GitHub" =>@repo
      },
      maintainers: ["Alex Wolf <swolf.dev@gmail.com>"]
    ]
  end
end

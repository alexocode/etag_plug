defmodule ETagPlug.MixProject do
  use Mix.Project

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
      source_url: "https://github.com/Zeeker/etag_plug",
      homepage_url: "https://github.com/Zeeker/etag_plug",

      # Hex
      description: description(),
      package: package(),
      version: "0.1.0"
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

      # Test
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  def description do
    "A simple to use plug for shallow ETags"
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Zeeker/etag_plug"
      },
      maintainers: ["Sascha Wolf <swolf.dev@gmail.com>"]
    ]
  end
end

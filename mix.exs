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
      source_url: "https://github.com/sascha-wolf/etag_plug",
      homepage_url: "https://github.com/sascha-wolf/etag_plug",

      # Hex
      description: description(),
      package: package(),
      version: version()
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
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},

      # Test
      {:excoveralls, "~> 0.17", only: :test}
    ]
  end

  def description do
    "A straight-forward plug for shallow ETags"
  end

  def package do
    [
      files: ["lib", "mix.exs", "CHANGELOG*", "LICENSE*", "README*", "version"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/sascha-wolf/knigge"
      },
      maintainers: ["Sascha Wolf <dev@saschawolf.me>"]
    ]
  end

  @version_file "version"
  def version do
    cond do
      File.exists?(@version_file) ->
        @version_file
        |> File.read!()
        |> String.trim()

      System.get_env("REQUIRE_VERSION_FILE") == "true" ->
        exit("Version file (`#{@version_file}`) doesn't exist but is required!")

      true ->
        "0.0.0-dev"
    end
  end
end

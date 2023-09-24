defmodule ExArray.MixProject do
  use Mix.Project

  def project do
    [
      app: :exarray,
      description: "An array-like data structure for Elixir",
      version: "0.1.2",
      source_url: "https://github.com/tajacks/ex_array",
      homepage_url: "https://github.com/tajacks/ex_array",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: [:error_handling, :unknown],
        # Error out when an ignore rule is no longer useful so we can remove it
        list_unused_filters: true
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.30.6", only: :dev, runtime: false},
      {:benchee, "~> 1.0", only: :dev},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.17.1", only: :test},
      {:dialyxir, "~> 1.4.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      name: "exarray",
      licenses: ["LGPL-3.0-only"],
      links: %{"GitHub" => "https://github.com/tajacks/ex_array"}
    ]
  end
end

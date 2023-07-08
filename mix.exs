defmodule ExArray.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_array,
      description: "An array-like data structure for Elixir",
      version: "0.1.0",
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
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:benchee, "~> 1.0", only: :dev},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false}
    ]
  end


  defp package do
    [
      name: "ex_array",
      licenses: ["LGPL-3.0-only"],
      links: %{"GitHub" => "https://github.com/tajacks/ex_array"}
    ]
  end
end

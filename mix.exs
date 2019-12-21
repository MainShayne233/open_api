defmodule OpenAPI.MixProject do
  use Mix.Project

  def project do
    [
      app: :open_api,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:breakfast, path: "../breakfast"},
      # {:breakfast, github: "MainShayne233/breakfast", branch: "master"},
      {:jason, "~> 1.1", only: :dev},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end
end

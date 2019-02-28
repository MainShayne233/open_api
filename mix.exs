defmodule OpenAPI.MixProject do
  use Mix.Project

  def project do
    [
      app: :open_api,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    []
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/open_api.plt"}
    ]
  rescue
    _ ->
      []
  end

  defp deps do
    [
      {:jason, "~> 1.1", only: [:test]},
      {:typed_struct, "~> 0.1.4"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end
end

defmodule ConnectedNodesDashboard.MixProject do
  use Mix.Project

  def project do
    [
      app: :connected_nodes_dashboard,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Connected Nodes Dashboard",
      source_url: "https://github.com/kkondaurov/connected_nodes_dashboard",
      description: description(),
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_dashboard, "~> 0.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    """
    An additional page for Phoenix LiveDashboard with information about connected nodes
    """
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      maintainers: ["Konstantin Kondaurov"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/kkondaurov/connected_nodes_dashboard"}
    ]
  end
end

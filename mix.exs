defmodule CosmoxEctoAdapter.MixProject do
  use Mix.Project

  def project do
    [
      app: :cosmox_ecto_adater,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:cosmox, "~> 0.1.0"},
      {:ecto, "~> 3.8"},
      {:uuid, "~> 1.1"},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:ex_doc, "~> 0.28.5", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

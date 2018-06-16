defmodule Lex.MixProject do
  use Mix.Project

  def project do
    [
      app: :lex,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [ extra_applications: [:logger, :httpoison] ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, ">= 1.2.0", optional: true},
      {:httpotion, ">= 3.0.0", optional: true},
      {:jason, ">= 1.0.0", optional: true},
      {:http_builder, ">= 0.4.1"},
      {:hackney, ">= 1.12.0"},
      {:aws_auth, "~> 0.7.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end

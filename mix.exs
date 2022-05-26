defmodule SemanticMarkdown.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_semantic_markdown,
      version: "0.1.0",
      description: "Markdown parser with support for semantic structure/tagging",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/exlee/ex_semantic_markdown",
      homepage_url: "https://github.com/exlee/ex_semantic_markdown",
      licenses: ["MIT"],
      docs: [
        main: "SemanticMarkdown",
        extras: ["README.md"],
        deps: [earmark: "https://hexdocs.pm/earmark"]
      ]
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
      {:earmark, "~> 1.4"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

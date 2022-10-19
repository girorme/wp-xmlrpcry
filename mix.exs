defmodule WpXmlrpcry.MixProject do
  use Mix.Project

  def project do
    [
      app: :wp_xmlrpcry,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: WpXmlrpcry]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WpXmlrpcry.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poolboy, "~> 1.5"},
      {:progress_bar, "> 0.0.0"}
    ]
  end
end

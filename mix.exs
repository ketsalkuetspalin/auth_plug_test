defmodule ResuelveAuth.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @description """
  Resuelve library to ensure authentication
  """

  def project do
    [
      app: :resuelve_auth,
      version: @version,
      elixir: "~> 1.4",
      description: @description,
      package: package(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  defp docs do
    [
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:phoenix,      "~> 1.3.0-rc", optional: true},
      {:plug,         "~> 1.3"},
      {:httpoison,    "~> 0.11.1"}, # Herramienta para facilitar peticiones http
      {:poison,       ">= 1.3.0"}, # Herramietna para facilitar el parseo de json

      # Dev and Test dependencies

      {:credo,        "~> 0.6.1", only: [:dev, :test]}, # Herrameinta para analisis de codigo
      {:excoveralls,  "~> 0.6",  only: :test}, # Coverage de pruebas unitarias
    ]
  end

  defp package do
    [ maintainers: ["RTD TEAM"],
      licenses: ["Resuelve"],
      links: %{"Bitbucket" => "https://bitbucket.org/resuelve/resuelveauth"} ]
  end

end

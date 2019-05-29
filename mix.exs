defmodule Particle.Mixfile do
  use Mix.Project

  def project do
    [
      app: :particle,
      version: "1.0.0",
      elixir: "~> 1.6",
      name: "Particle Api Client",
      source_url: "https://github.com/jeffutter/particle-elixir.ex",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      docs: [
        extras: ["README.md"]
      ],
      package: package(),
      deps: deps(),
      description: description()
    ]
  end

  def application do
    [applications: [:hackney, :gen_stage, :logger], mod: {Particle, []}]
  end

  defp description do
    """
    Client library for the Particle Cloud API.
    """
  end

  defp deps do
    [
      {:gen_stage, "~> 0.12"},
      {:hackney, "~> 1.6"},
      {:jason, "~> 1.1"},
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.12", only: :dev},
      {:inch_ex, "~> 2.0", only: [:dev, :test]},
      {:exvcr, "~> 0.7", only: :test}
    ]
  end

  def package do
    [
      name: :particle,
      maintainers: ["Jeffery Utter"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/jeffutter/particle-elixir"}
    ]
  end
end

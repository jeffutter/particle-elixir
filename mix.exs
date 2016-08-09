defmodule Particle.Mixfile do
  use Mix.Project

  def project do
    [app: :particle,
     version: "0.1.0",
     elixir: "~> 1.3",
     name: "Particle Api Client",
     source_url: "https://github.com/jeffutter/particle-elixir.ex",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     docs: [
       extras: ["README.md"]
     ],
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:httpoison, :logger, :poison],
     mod: {Particle, []}]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.2.0"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:ex_doc, "~> 0.12", only: :dev},
      {:exvcr, "~> 0.7", only: :test}
    ]
  end

  def package do
    [
      name: :particle,
      maintainer: ["Jeffery Utter"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/jeffutter/particle-elixir.ex"},
    ]
  end
end

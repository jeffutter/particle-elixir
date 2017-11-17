defmodule Particle.Mixfile do
  use Mix.Project

  def project do
    [app: :particle,
     version: "0.1.7",
     elixir: "~> 1.3",
     name: "Particle Api Client",
     source_url: "https://github.com/jeffutter/particle-elixir.ex",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     docs: [
       extras: ["README.md"]
     ],
     package: package(),
     deps: deps(),
     description: description()
   ]
  end

  def application do
    [applications: [:hackney, :gen_stage, :logger, :poison],
     mod: {Particle, []}]
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
      {:poison, "~> 3.0"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:ex_doc, "~> 0.12", only: :dev},
      {:inch_ex, "~> 0.5", only: [:dev, :test]},
      {:exvcr, "~> 0.7", only: :test}
    ]
  end

  def package do
    [
      name: :particle,
      maintainers: ["Jeffery Utter"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/jeffutter/particle-elixir"},
    ]
  end
end

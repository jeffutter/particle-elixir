# Particle

Particle Cloud API Client for Elixir:

This is an unofficial client for the [Particle IoT platform's HTTP API](https://docs.particle.io/reference/api/). 

## Usage

Installation

```elixir
def deps do
  [{:particle, "~> 0.1.0"}]
end
```

and run `mix deps.get`. Now, list the :particle application nas your application dependency:

```elixir
def application do
  [applications: [:particle]]
end
```

## Configuration

You will need to set the following configuration variables in your `config/config.exs` file:

```elixir
use Mix.Config

config :particle,
  particle_key: System.get_env("PARTICLE_KEY")
```

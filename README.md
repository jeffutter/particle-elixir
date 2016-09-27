# Particle

[![Build Status](https://travis-ci.org/jeffutter/particle-elixir.svg?branch=master)](https://travis-ci.org/jeffutter/particle-elixir)
[![Hex.pm](https://img.shields.io/hexpm/v/particle.svg?maxAge=2592000)](https://hex.pm/packages/particle)
[![Inline docs](http://inch-ci.org/github/jeffutter/particle-elixir.svg)](http://inch-ci.org/github/jeffutter/particle-elixir)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/jeffutter/particle-elixir.svg)](https://beta.hexfaktor.org/github/jeffutter/particle-elixir)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

Particle Cloud API Client for Elixir:

This is an unofficial client for the [Particle IoT platform's HTTP API](https://docs.particle.io/reference/api/). 

## Usage

Installation

```elixir
def deps do
  [{:particle, "~> 0.1.0"}]
end
```

and run `mix deps.get`. Now, list the :particle application as your application dependency:

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

## Stream Usage

Create a module responsible for the handling of the events. Customize `handle_events` for your application.

```elixir
defmodule MyApp.ParticleEventHandler do
  alias Experimental.GenStage
  alias Particle.Stream

  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [Stream]}
  end

  def handle_events(events, _from, state) do
    IO.inspect events
    {:noreply, [], state}
  end
end
```

Start the workers in de `Application`.

```elixir
defmodule MyApp do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Particle.Stream, ["https://api.particle.io/v1/devices/events/status"]), # define url here
      worker(MyApp.ParticleEventHandler, [])
    ]
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

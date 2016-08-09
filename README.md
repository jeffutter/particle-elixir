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

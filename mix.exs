defmodule Hatch.MixProject do
  use Mix.Project

  def project do
    [
      app: :hatch,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Hatch.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:spawn_sdk, path: "../../eigr/spawn/spawn_sdk/spawn_sdk"},
      {:spawn_sdk, path: "../oss/spawn/spawn_sdk/spawn_sdk"},
      {:uniq, "~> 0.5.3"}
    ]
  end
end

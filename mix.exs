defmodule J1605Mqtt.MixProject do
  use Mix.Project

  def project do
    [
      app: :j1605_mqtt,
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
      mod: {J1605Mqtt.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:j1605, "~> 0.3.0"},
      {:tortoise, "~> 0.10.0"}
    ]
  end
end

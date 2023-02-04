defmodule ImageLite.MixProject do
  use Mix.Project

  def project do
    [
      app: :image_lite,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:vix, "~> 0.16"},
      {:sweet_xml, "~> 0.7"},
      {:test_iex, github: "mindreframer/test_iex", only: [:test, :dev]}
    ]
  end
end

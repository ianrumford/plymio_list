defmodule PlymioList.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :plymio_list,
     version: @version,
     description: description(),
     package: package(),
     source_url: "https://github.com/ianrumford/plymio_list",
     homepage_url: "https://github.com/ianrumford/plymio_list",
     docs: [extras: ["./README.md", "./CHANGELOG.md"]],
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.14.5", only: :dev}
    ]
  end

  defp package do
    [maintainers: ["Ian Rumford"],
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/ianrumford/plymio_list"}]
  end

  defp description do
    """
    plymio_list: Utility Functions for Lists

    plymio is a family of utility function packages
    """
  end

end

defmodule Daeventbox.Mixfile do
  use Mix.Project

  def project do
    [
      app: :daeventbox,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Daeventbox.Application, []},
      extra_applications: [:logger, :runtime_tools, :bamboo, :hackney, :ex_aws]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:hasher, "~> 0.1.0"},
      {:comeonin, "~> 4.0"},
      {:guardian, "~> 1.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:calecto, "~> 0.16.0"},
      {:elixlsx, "~> 0.4.0"},
      {:bamboo, "~> 0.8"},
      #{:fitz, github: "SirFitz/fitz", override: true},
      #{:data, git: "git@bitbucket.org:sirfitz/data.git"},
      {:arc, "~> 0.8.0"},
      {:ex_aws, "~> 2.0", override: true},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end

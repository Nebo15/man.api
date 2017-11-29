defmodule Man.ReleaseTasks do
  @moduledoc """
  Nice way to apply migrations inside a released application.

  Example:

      man_api/bin/man_api command Elixir.Man.ReleaseTasks migrate!
  """
  alias Ecto.Migrator

  @start_apps [
    :logger,
    :postgrex,
    :ecto
  ]

  @apps [
    :man_api
  ]

  @repos [
    Man.Repo
  ]

  def migrate! do
    IO.puts "Loading man_api.."
    # Load the code for man_api, but don't start it
    :ok = Application.load(:man_api)

    IO.puts "Starting dependencies.."
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for man_api
    IO.puts "Starting repos.."
    Enum.each(@repos, &(&1.start_link(pool_size: 1)))

    # Run migrations
    Enum.each(@apps, &run_migrations_for/1)

    # Run the seed script if it exists
    seed_script = seed_path(:man_api)
    if File.exists?(seed_script) do
      IO.puts "Running seed script.."
      Code.eval_file(seed_script)
    end

    # Signal shutdown
    IO.puts "Success!"
    :init.stop()
  end

  def priv_dir(app),
    do: :code.priv_dir(app)

  defp run_migrations_for(app) do
    IO.puts "Running migrations for #{app}"
    Enum.each(@repos, &Migrator.run(&1, migrations_path(app), :up, all: true))
  end

  defp migrations_path(app), do: Application.app_dir(:man_api, "priv/repo/migrations")
  defp seed_path(app), do: Application.app_dir(:man_api, "priv/repo/seeds")
end

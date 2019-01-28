defmodule Man.ReleaseTasks do
  @moduledoc """
  Nice way to apply migrations inside a released application.

  Example:

      man_api/bin/man_api command Elixir.Man.ReleaseTasks migrate
  """
  alias Ecto.Migrator

  @start_apps [
    :logger,
    :postgrex,
    :ecto
  ]
  @app :man_api
  @repo Man.Repo

  def migrate do
    migrations_dir = Application.app_dir(:man_api, "priv/repo/migrations")

    @repo
    |> start_repo
    |> Migrator.run(migrations_dir, :up, all: true)

    # Run the seed script if it exists
    seed_script = seed_path(:man_api)

    if File.exists?(seed_script) do
      IO.puts("Running seed script..")
      Code.eval_file(seed_script)
    end

    # Signal shutdown
    IO.puts("Success!")
    System.halt(0)
    :init.stop()
  end

  defp start_repo(repo) do
    IO.puts("Starting dependencies..")
    start_applications(@start_apps)
    IO.puts("Loading man_api..")
    Application.load(@app)
    # If you don't include Repo in application supervisor start it here manually
    IO.puts("Starting repos..")
    repo.start_link(pool_size: 1)
    repo
  end

  defp start_applications(apps) do
    Enum.each(apps, fn app ->
      {_, _message} = Application.ensure_all_started(app)
    end)
  end

  def priv_dir(app), do: :code.priv_dir(app)

  defp seed_path(_app), do: Application.app_dir(:man_api, "priv/repo/seeds")
end

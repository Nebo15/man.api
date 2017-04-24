defmodule Man do
  @moduledoc """
  This is an entry point of Man application.
  """
  use Application
  alias Man.Web.Endpoint

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Configure Logger severity at runtime
    configure_log_level()

    # Define workers and child supervisors to be supervised
    children = [
      # Start cache supervisor
      supervisor(Man.Cache.Supervisor, []),
      # Start the Ecto repository
      supervisor(Man.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Endpoint, []),
      # Starts a worker by calling: Man.Worker.start_link(arg1, arg2, arg3)
      # worker(Man.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Man.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end

  # Loads configuration in `:on_init` callbacks and replaces `{:system, ..}` tuples via Confex
  @doc false
  def load_from_system_env(config) do
    {:ok, Confex.process_env(config)}
  end

  # Configures Logger level via LOG_LEVEL environment variable.
  defp configure_log_level do
    case System.get_env("LOG_LEVEL") do
      nil ->
        :ok
      level when level in ["debug", "info", "warn", "error"] ->
        Logger.configure(level: String.to_atom(level))
      level ->
        raise ArgumentError, "LOG_LEVEL environment should have one of 'debug', 'info', 'warn', 'error' values," <>
                             "got: #{inspect level}"
    end
  end
end

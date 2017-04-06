defmodule Printout do
  @moduledoc """
  This is an entry point of printout application.
  """

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Printout.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Printout.Web.Endpoint, []),
      # Starts a worker by calling: Printout.Worker.start_link(arg1, arg2, arg3)
      # worker(Printout.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Printout.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Printout.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end

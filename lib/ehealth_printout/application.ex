defmodule EhealthPrintout do
  @moduledoc """
  This is an entry point of ehealth_printout application.
  """

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(EhealthPrintout.Repo, []),
      # Start the endpoint when the application starts
      supervisor(EhealthPrintout.Web.Endpoint, []),
      # Starts a worker by calling: EhealthPrintout.Worker.start_link(arg1, arg2, arg3)
      # worker(EhealthPrintout.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EhealthPrintout.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EhealthPrintout.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end

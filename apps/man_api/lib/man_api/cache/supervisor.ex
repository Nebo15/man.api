defmodule Man.Cache.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  def init(_) do
    children = [
      worker(Man.Cache, [[name: Man.Cache]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

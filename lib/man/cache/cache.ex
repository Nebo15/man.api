defmodule Man.Cache do
  @moduledoc """
  This module provides cache interface that is used to store slow operations results, eg. Markdown-to-PDF outputs.
  """
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [
      {:ets_table_name, :man_cache_table},
      {:log_limit, 10_000}
    ], opts)
  end

  @doc false
  def init(args) do
    [{:ets_table_name, ets_table_name}, {:log_limit, log_limit}] = args
    :ets.new(ets_table_name, [:named_table, :set, :private])
    {:ok, %{log_limit: log_limit, ets_table_name: ets_table_name}}
  end

  def fetch(slug, default_value_function) do
    case get(slug) do
      {:not_found} -> set(slug, default_value_function.())
      {:found, result} -> result
    end
  end

  defp get(slug) do
    case GenServer.call(__MODULE__, {:get, slug}) do
      [] -> {:not_found}
      [{_slug, result}] -> {:found, result}
    end
  end

  defp set(slug, value) do
    GenServer.call(__MODULE__, {:set, slug, value})
  end

  # GenServer callbacks

  def handle_call({:get, slug}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.lookup(ets_table_name, slug)
    {:reply, result, state}
  end

  def handle_call({:set, slug, value}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    true = :ets.insert(ets_table_name, {slug, value})
    {:reply, value, state}
  end
end

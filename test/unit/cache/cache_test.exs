defmodule Man.CacheTest do
  use ExUnit.Case
  alias Man.Cache

  test "caches and finds the correct data" do
    assert Cache.fetch("A", fn ->
             %{id: 1, long_url: "http://www.example.com"}
           end) == %{id: 1, long_url: "http://www.example.com"}

    assert Cache.fetch("A", fn -> "" end) == %{id: 1, long_url: "http://www.example.com"}
  end
end

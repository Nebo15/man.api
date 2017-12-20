defmodule Man.Web.LabelControllerTest do
  use Man.Web.ConnCase, async: true
  alias Man.FixturesFactory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    assert [] ==
      conn
      |> get(label_path(conn, :index))
      |> json_response(200)
      |> Map.get("data")

    FixturesFactory.create(:template, labels: ["a", "b"])
    result =
      conn
      |> get(label_path(conn, :index))
      |> json_response(200)
      |> Map.get("data")

    assert Enum.sort(["b", "a"]) == Enum.sort(result)

    FixturesFactory.create(:template, labels: ["c", "d"])
    result =
      conn
      |> get(label_path(conn, :index))
      |> json_response(200)
      |> Map.get("data")

    assert Enum.sort(["b", "a", "c", "d"]) == Enum.sort(result)
    assert 4 == length(result)
  end
end

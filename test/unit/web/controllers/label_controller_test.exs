defmodule Man.Web.LabelControllerTest do
  use Man.Web.ConnCase, async: true
  alias Man.Templates.API
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
    assert ["b", "a"] =
      conn
      |> get(label_path(conn, :index))
      |> json_response(200)
      |> Map.get("data")

    FixturesFactory.create(:template, labels: ["c", "d"])
    result =
      conn
      |> get(label_path(conn, :index))
      |> json_response(200)
      |> Map.get("data")

    assert ["b", "a", "c", "d"] = result
    assert 4 == length(result)
  end
end

defmodule Man.Web.LabelControllerTest do
  use Man.Web.ConnCase
  alias Man.Templates.API

  @create_attrs %{body: "some body", validation_schema: %{}, title: "some title"}

  def fixture(:template, labels) do
    {:ok, template} =
      @create_attrs
      |> Map.put(:labels, labels)
      |> API.create_template()

    template
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, label_path(conn, :index)
    assert json_response(conn, 200)["data"] == []

    fixture(:template, ["a", "b"])
    conn = get conn, label_path(conn, :index)
    assert json_response(conn, 200)["data"] == ["b", "a"]

    fixture(:template, ["c", "d"])
    conn = get conn, label_path(conn, :index)
    assert json_response(conn, 200)["data"] == ["b", "a", "c", "d"]
  end
end

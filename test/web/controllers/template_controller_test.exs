defmodule Printout.Web.TemplateControllerTest do
  use Printout.Web.ConnCase

  alias Printout.TemplateAPI
  alias Printout.TemplateAPI.Template

  @create_attrs %{body: "some body", json_schema: %{}}
  @update_attrs %{body: "some updated body", json_schema: %{}}
  @invalid_attrs %{body: nil, json_schema: nil}
  @template_body "<div><h1><%= @h1 %></h1><h2><%= @h2 %></h2></div>"
  @all_print_attrs %{h1: "some data", h2: "another data"}
  @h1_valid_print_attr %{h1: "some data"}
  @h1_invalid_print_attr %{h1: 111}
  @full_rendered_template "<div><h1>some data</h1><h2>another data</h2></div>"
  @partially_rendered_template "<div><h1>some data</h1><h2></h2></div>"
  @empty_rendered_template "<div><h1></h1><h2></h2></div>"
  @json_schema %{
    "type": "object",
    "required": [
      "h1"
    ],
    "properties": %{
      "h1": %{
        "type": "string"
      }
    }
  }

  def fixture(:template, attrs \\ @create_attrs) do
    {:ok, template} = TemplateAPI.create_template(attrs)
    template
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, template_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates template and renders template when data is valid", %{conn: conn} do
    conn = post conn, template_path(conn, :create), @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, template_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "body" => "some body",
      "json_schema" => %{},
      "type" => "template"}
  end

  test "does not create template and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, template_path(conn, :create), @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen template and renders template when data is valid", %{conn: conn} do
    %Template{id: id} = template = fixture(:template)
    conn = put conn, template_path(conn, :update, template), @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, template_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "body" => "some updated body",
      "json_schema" => %{},
      "type" => "template"}
  end

  test "does not update chosen template and renders errors when data is invalid", %{conn: conn} do
    template = fixture(:template)
    conn = put conn, template_path(conn, :update, template), @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen template", %{conn: conn} do
    template = fixture(:template)
    conn = delete conn, template_path(conn, :delete, template)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, template_path(conn, :show, template)
    end
  end

  test "prints template with all parameters", %{conn: conn} do
    template = fixture(:template, %{body: @template_body, json_schema: %{}})
    conn = post conn, template_path(conn, :print, template), @all_print_attrs
    assert @full_rendered_template = html_response(conn, 200)
  end

  test "prints template without all parameters", %{conn: conn} do
    template = fixture(:template, %{body: @template_body, json_schema: %{}})
    conn = post conn, template_path(conn, :print, template), @h1_valid_print_attr
    assert @partially_rendered_template = html_response(conn, 200)
  end

  test "prints template without parameters", %{conn: conn} do
    template = fixture(:template, %{body: @template_body, json_schema: %{}})
    conn = post conn, template_path(conn, :print, template), %{}
    assert @empty_rendered_template = html_response(conn, 200)
  end

  test "validates missing print parameter", %{conn: conn} do
    template = fixture(:template, %{body: @template_body, json_schema: @json_schema})
    conn = post conn, template_path(conn, :print, template), %{}
    assert %{"invalid" => _} = json_response(conn, 422)
  end

  test "validates invalid print parameter", %{conn: conn} do
    template = fixture(:template, %{body: @template_body, json_schema: @json_schema})
    conn = post conn, template_path(conn, :print, template), @h1_invalid_print_attr
    assert %{"invalid" => _} = json_response(conn, 422)
  end

  test "validates valid print parameter", %{conn: conn} do
    template = fixture(:template, %{body: @template_body, json_schema: @json_schema})
    conn = post conn, template_path(conn, :print, template), @h1_valid_print_attr
    assert @partially_rendered_template = html_response(conn, 200)
  end
end
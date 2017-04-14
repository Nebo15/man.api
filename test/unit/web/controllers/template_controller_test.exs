defmodule Man.Web.TemplateControllerTest do
  use Man.Web.ConnCase
  alias Man.Templates.API
  alias Man.Templates.Template

  @create_attrs %{body: "some body", validation_schema: %{}, title: "some title"}
  @update_attrs %{body: "some updated body", validation_schema: %{}, title: "some title"}
  @replace_attrs %{body: "some replaced body", validation_schema: %{}, title: "some replaced title"}
  @invalid_attrs %{body: nil, validation_schema: nil, title: nil, labels: [1, 2, 3]}
  @template_body "<div><h1><%= @h1 %></h1><h2><%= @h2 %></h2></div>"
  @all_print_attrs %{h1: "some data", h2: "another data"}
  @h1_valid_print_attr %{h1: "some data"}
  @h1_invalid_print_attr %{h1: 111}
  @full_rendered_template "<div><h1>some data</h1><h2>another data</h2></div>"
  @partially_rendered_template "<div><h1>some data</h1><h2></h2></div>"
  @empty_rendered_template "<div><h1></h1><h2></h2></div>"
  @validation_schema %{
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
    {:ok, template} = API.create_template(attrs)
    template
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, template_path(conn, :index)
    assert json_response(conn, 200)["data"] == []

    %Template{id: id1} = template = fixture(:template)
    %Template{id: id2} = template = fixture(:template, Map.put(@create_attrs, :title, "other title"))

    conn = get conn, template_path(conn, :index)
    assert [%{"id" => ^id1}, %{"id" => ^id2}] = json_response(conn, 200)["data"]

    conn = get conn, template_path(conn, :index, %{"title" => "some"})
    assert [%{"id" => ^id1}] = json_response(conn, 200)["data"]
  end

  test "creates template and renders template when data is valid", %{conn: conn} do
    conn = post conn, template_path(conn, :create), @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, template_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "body" => "some body",
      "validation_schema" => %{},
      "type" => "template",
      "description" => nil,
      "labels" => [],
      "locales" => [],
      "syntax" => "mustache",
      "title" => "some title"}
  end

  test "does not create template and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, template_path(conn, :create), @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen template and renders template when data is valid", %{conn: conn} do
    %Template{id: id} = template = fixture(:template)
    conn = patch conn, template_path(conn, :update, template), @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, template_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "body" => "some updated body",
      "validation_schema" => %{},
      "type" => "template",
      "description" => nil,
      "labels" => [],
      "locales" => [],
      "syntax" => "mustache",
      "title" => "some title"}
  end

  test "does not update chosen template and renders errors when data is invalid", %{conn: conn} do
    template = fixture(:template)
    conn = patch conn, template_path(conn, :update, template), @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "replace chosen template and renders template when data is valid", %{conn: conn} do
    %Template{id: id} = template = fixture(:template, Map.put(@create_attrs, :description, "Some content"))
    conn = put conn, template_path(conn, :replace, template), @replace_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, template_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "body" => "some replaced body",
      "validation_schema" => %{},
      "type" => "template",
      "description" => nil,
      "labels" => [],
      "locales" => [],
      "syntax" => "mustache",
      "title" => "some replaced title"}
  end

  # test "does not replace chosen template and renders errors when data is invalid", %{conn: conn} do
  #   template = fixture(:template)
  #   conn = put conn, template_path(conn, :replace, template), @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  test "deletes chosen template", %{conn: conn} do
    template = fixture(:template)
    conn = delete conn, template_path(conn, :delete, template)
    assert response(conn, 204)
    resp = get conn, template_path(conn, :show, template)

    assert resp.status == 404
    assert resp.state == :sent
  end

  # test "prints template with all parameters", %{conn: conn} do
  #   template = fixture(:template, %{body: @template_body, validation_schema: %{}})
  #   conn = post conn, template_path(conn, :print, template), @all_print_attrs
  #   assert @full_rendered_template = html_response(conn, 200)
  # end

  # test "prints template without all parameters", %{conn: conn} do
  #   template = fixture(:template, %{body: @template_body, validation_schema: %{}})
  #   conn = post conn, template_path(conn, :print, template), @h1_valid_print_attr
  #   assert @partially_rendered_template = html_response(conn, 200)
  # end

  # test "prints template without parameters", %{conn: conn} do
  #   template = fixture(:template, %{body: @template_body, validation_schema: %{}})
  #   conn = post conn, template_path(conn, :print, template), %{}
  #   assert @empty_rendered_template = html_response(conn, 200)
  # end

  # test "validates missing print parameter", %{conn: conn} do
  #   template = fixture(:template, %{body: @template_body, validation_schema: @validation_schema})
  #   conn = post conn, template_path(conn, :print, template), %{}
  #   assert %{"invalid" => _} = json_response(conn, 422)
  # end

  # test "validates invalid print parameter", %{conn: conn} do
  #   template = fixture(:template, %{body: @template_body, validation_schema: @validation_schema})
  #   conn = post conn, template_path(conn, :print, template), @h1_invalid_print_attr
  #   assert %{"invalid" => _} = json_response(conn, 422)
  # end

  # test "validates valid print parameter", %{conn: conn} do
  #   template = fixture(:template, %{body: @template_body, validation_schema: @validation_schema})
  #   conn = post conn, template_path(conn, :print, template), @h1_valid_print_attr
  #   assert @partially_rendered_template = html_response(conn, 200)
  # end
end

defmodule Man.Web.TemplateControllerTest do
  use Man.Web.ConnCase, async: true
  alias Man.Templates.API
  alias Man.Templates.Template

  @create_attrs %{body: "some body", validation_schema: %{}, title: "some title"}
  @update_attrs %{body: "some updated body", validation_schema: %{}, title: "some title"}
  @replace_attrs %{body: "some replaced body", validation_schema: %{}, title: "some replaced title"}
  @invalid_attrs %{body: nil, validation_schema: nil, title: nil, labels: [1, 2, 3]}
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
    {:ok, conn: put_req_header(conn, "accept", "application/json"), raw_conn: conn}
  end

  test "lists and filters all entries on index", %{conn: conn} do
    conn = get conn, template_path(conn, :index)
    assert json_response(conn, 200)["data"] == []

    %Template{id: id1} = fixture(:template)

    other_params =
      @create_attrs
      |> Map.put(:title, "other title")
      |> Map.put(:labels, ["label/one", "label/two"])

    %Template{id: id2} = fixture(:template, other_params)

    conn = get conn, template_path(conn, :index)
    assert [%{"id" => ^id1}, %{"id" => ^id2}] = json_response(conn, 200)["data"]

    # Filter by title
    conn = get conn, template_path(conn, :index, %{"title" => "some"})
    assert [%{"id" => ^id1}] = json_response(conn, 200)["data"]

    # Filter by label
    conn = get conn, template_path(conn, :index, %{"labels" => "label/one"})
    assert [%{"id" => ^id2}] = json_response(conn, 200)["data"]

    conn = get conn, template_path(conn, :index, %{"labels" => "label/one,label/two"})
    assert [%{"id" => ^id2}] = json_response(conn, 200)["data"]
  end

  test "paginates entries on index", %{conn: conn} do
    template_data =
      @create_attrs
      |> Map.put(:labels, ["label/one", "label/two"])

    %Template{id: id1} = fixture(:template, template_data)
    %Template{id: id2} = fixture(:template, template_data)
    %Template{id: id3} = fixture(:template, template_data)
    %Template{id: id4} = fixture(:template, template_data)
    %Template{id: id5} = fixture(:template, template_data)

    conn = get conn, template_path(conn, :index), %{"limit" => 1}
    assert [%{"id" => ^id1}] = json_response(conn, 200)["data"]

    conn = get conn, template_path(conn, :index), %{"limit" => 2}
    assert [%{"id" => ^id1}, %{"id" => ^id2}] = json_response(conn, 200)["data"]

    conn = get conn, template_path(conn, :index), %{"limit" => 2, "starting_after" => id2}
    assert [%{"id" => ^id3}, %{"id" => ^id4}] = json_response(conn, 200)["data"]

    conn = get conn, template_path(conn, :index), %{"limit" => 2, "ending_before" => id5}
    assert [%{"id" => ^id3}, %{"id" => ^id4}] = json_response(conn, 200)["data"]

    conn = get conn, template_path(conn, :index), %{"limit" => 2, "ending_before" => id5, "title" => "some"}
    assert [%{"id" => ^id3}, %{"id" => ^id4}] = json_response(conn, 200)["data"]

    conn = get conn, template_path(conn, :index), %{"limit" => 2, "ending_before" => id5, "labels" => "label/one"}
    assert [%{"id" => ^id3}, %{"id" => ^id4}] = json_response(conn, 200)["data"]
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
    assert %{
      "error" => %{
        "invalid" => [
          %{"entry" => "$.body", "entry_type" => "json_data_property", "rules" => [
            %{"description" => "can't be blank", "params" => [], "rule" => "required"}
          ]},
          %{"entry" => "$.labels", "entry_type" => "json_data_property", "rules" => [
            %{"description" => "is invalid", "params" => ["strings_array"], "rule" => "cast"}
          ]},
          %{"entry" => "$.title", "entry_type" => "json_data_property", "rules" => [
            %{"description" => "can't be blank", "params" => [], "rule" => "required"}
          ]},
        ],
        "type" => "validation_failed"
      }
    } = json_response(conn, 422)
  end

  test "does not create template and renders errors when locales are duplicated", %{conn: conn} do
    attrs = Map.put(@create_attrs, :locales, [
      %{"code" => "en_US", "params" => %{}},
      %{"code" => "en_US", "params" => %{}},
    ])
    conn = post conn, template_path(conn, :create), attrs
    assert %{
      "error" => %{
        "invalid" => [
          %{"entry" => "$.locales", "entry_type" => "json_data_property", "rules" => [
            %{"description" => "contains duplicate fields", "params" => [], "rule" => ["unique"]},
          ]}
        ],
        "type" => "validation_failed"
      }
    } = json_response(conn, 422)
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

  test "does not replace chosen template and renders errors when data is invalid", %{conn: conn} do
    template = fixture(:template)
    conn = put conn, template_path(conn, :replace, template), @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen template", %{conn: conn} do
    template = fixture(:template)
    conn = delete conn, template_path(conn, :delete, template)
    assert response(conn, 204)
    resp = get conn, template_path(conn, :show, template)

    assert resp.status == 404
    assert resp.state == :sent
  end

  describe "mustache renderer" do
    test "with json format", %{conn: conn} do
      attrs = Map.put(@create_attrs, :body, "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
      template = fixture(:template, attrs)
      conn = post conn, template_path(conn, :render, template), %{"h1" => "some data", "h2" => "another data"}
      assert %{"body" => "<div><h1>some data</h1><h2>another data</h2></div>"} == json_response(conn, 200)
    end

    test "with html format", %{raw_conn: conn} do
      attrs = Map.put(@create_attrs, :body, "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
      template = fixture(:template, attrs)
      req_attrs = %{"h1" => "some data", "h2" => "another data", "format" => "text/html"}
      conn = post(conn, template_path(conn, :render, template), req_attrs)
      assert "<div><h1>some data</h1><h2>another data</h2></div>" == html_response(conn, 200)
    end

    test "with PDF format", %{raw_conn: conn} do
      attrs = Map.put(@create_attrs, :body, "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
      template = fixture(:template, attrs)
      req_attrs = %{"h1" => "some data", "h2" => "another data", "format" => "application/pdf"}
      conn = post(conn, template_path(conn, :render, template), req_attrs)
      assert <<37, 80, 68, 70, 45, 49, 46, 52, 10, _rest::binary>> = response(conn, 200)
    end

    test "with PDF format in Accept header", %{raw_conn: conn} do
      attrs = Map.put(@create_attrs, :body, "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
      template = fixture(:template, attrs)
      req_attrs = %{"h1" => "some data", "h2" => "another data"}

      conn =
        conn
        |> put_req_header("accept", "application/pdf")
        |> post(template_path(conn, :render, template), req_attrs)

      assert <<37, 80, 68, 70, 45, 49, 46, 52, 10, _rest::binary>> = response(conn, 200)
    end

    test "does not require all attributes", %{conn: conn} do
      attrs = Map.put(@create_attrs, :body, "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
      template = fixture(:template, attrs)
      conn = post conn, template_path(conn, :render, template), %{}
      assert %{"body" => @empty_rendered_template} == json_response(conn, 200)
    end
  end

  describe "markdown renderer" do
    test "with json format", %{conn: conn} do
      attrs =
        @create_attrs
        |> Map.put(:syntax, "markdown")
        |> Map.put(:body, """
          # Hello
          world
        """)
      template = fixture(:template, attrs)
      conn = post conn, template_path(conn, :render, template), %{}
      assert %{"body" => "<p>  # Hello\n  world</p>\n"} == json_response(conn, 200)
    end

    test "with html format", %{raw_conn: conn} do
      attrs =
        @create_attrs
        |> Map.put(:syntax, "markdown")
        |> Map.put(:body, """
          # Hello
          world
        """)
      template = fixture(:template, attrs)
      req_attrs = %{"format" => "text/html"}
      conn = post(conn, template_path(conn, :render, template), req_attrs)
      assert "<p>  # Hello\n  world</p>\n" == html_response(conn, 200)
    end
  end

  describe "iex renderer" do
    test "with json format", %{conn: conn} do
      attrs =
        @create_attrs
        |> Map.put(:syntax, "iex")
        |> Map.put(:body, "<div><h1><%= @h1 %></h1><h2><%= @h2 %></h2></div>")

      template = fixture(:template, attrs)
      conn = post conn, template_path(conn, :render, template), %{"h1" => "some data", "h2" => "another data"}
      assert %{"body" => "<div><h1>some data</h1><h2>another data</h2></div>"} == json_response(conn, 200)
    end

    test "with html format", %{raw_conn: conn} do
      attrs =
        @create_attrs
        |> Map.put(:syntax, "iex")
        |> Map.put(:body, "<div><h1><%= @h1 %></h1><h2><%= @h2 %></h2></div>")

      template = fixture(:template, attrs)
      req_attrs = %{"h1" => "some data", "h2" => "another data", "format" => "text/html"}
      conn = post(conn, template_path(conn, :render, template), req_attrs)
      assert "<div><h1>some data</h1><h2>another data</h2></div>" == html_response(conn, 200)
    end

    test "does not require all attributes", %{conn: conn} do
      attrs =
        @create_attrs
        |> Map.put(:syntax, "iex")
        |> Map.put(:body, "<div><h1><%= @h1 %></h1><h2><%= @h2 %></h2></div>")

      template = fixture(:template, attrs)
      conn = post conn, template_path(conn, :render, template), %{}
      assert %{"body" => @empty_rendered_template} == json_response(conn, 200)
    end
  end

  test "takes format from Accept header", %{raw_conn: conn} do
    template = fixture(:template)
    req_attrs = %{"h1" => "some data", "h2" => "another data", "format" => "text/html"}

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> post(template_path(conn, :render, template), req_attrs)

    assert %{"body" => "some body"} == json_response(conn, 200)
  end

  test "returns error on unsupported format", %{raw_conn: conn} do
    attrs = Map.put(@create_attrs, :body, "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
    template = fixture(:template, attrs)
    req_attrs = %{"h1" => "some data", "h2" => "another data", "format" => "some/format"}
    conn = post(conn, template_path(conn, :render, template), req_attrs)
    assert %{
      "invalid" => [
        %{"entry" => "Content-Type", "entry_type" => "header"}
      ],
      "type" => "content_type_invalid"
    } = json_response(conn, 415)
  end

  test "validates template attributes with json schema", %{conn: conn} do
    attrs =
      @create_attrs
      |> Map.put(:body, "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
      |> Map.put(:validation_schema, @validation_schema)

    template = fixture(:template, attrs)
    conn = post conn, template_path(conn, :render, template), %{"h2" => "another data"}
    assert %{
      "invalid" => [
        %{"entry" => "$", "entry_type" => "json_data_property", "rules" => [
          %{"description" => "required property h1 was not present", "params" => [], "rule" => "required"}
        ]}
      ],
      "type" => "validation_failed"
    } = json_response(conn, 422)
  end

  test "takes locale from Accept-Language header", %{conn: conn} do
    attrs =
      @create_attrs
      |> Map.put(:body, "<div><h1>{{l10n.hello}} {{h1}}</h1><h2>{{h2}}</h2></div>")
      |> Map.put(:locales, [%{"code" => "es_ES", "params" => %{"hello" => "Hola"}}])

    template = fixture(:template, attrs)
    conn =
      conn
      |> put_req_header("accept-language", "es_ES")
      |> post(template_path(conn, :render, template), %{"h1" => "world", "locale" => "en_US"})

    assert %{"body" => "<div><h1>Hola world</h1><h2></h2></div>"} == json_response(conn, 200)
  end

  test "localizes templates with default locale", %{conn: conn} do
    attrs =
      @create_attrs
      |> Map.put(:body, "<div><h1>{{l10n.hello}} {{h1}}</h1><h2>{{h2}}</h2></div>")
      |> Map.put(:locales, [%{"code" => "es_ES", "params" => %{"hello" => "Hola"}}])

    template = fixture(:template, attrs)
    conn = post conn, template_path(conn, :render, template), %{"h1" => "world"}
    assert %{"body" => "<div><h1>Hola world</h1><h2></h2></div>"} == json_response(conn, 200)
  end

  test "localizes templates with multiple locales", %{conn: conn} do
    attrs =
      @create_attrs
      |> Map.put(:body, "<div><h1>{{l10n.hello}} {{h1}}</h1><h2>{{h2}}</h2></div>")
      |> Map.put(:locales, [
        %{"code" => "es_ES", "params" => %{"hello" => "Hola"}},
        %{"code" => "en_US", "params" => %{"hello" => "Hello"}},
      ])

    template = fixture(:template, attrs)
    conn = post conn, template_path(conn, :render, template), %{"h1" => "world", "locale" => "en_US"}
    assert %{"body" => "<div><h1>Hello world</h1><h2></h2></div>"} == json_response(conn, 200)
  end

  test "returns error when locale is not set", %{conn: conn} do
    attrs =
      @create_attrs
      |> Map.put(:body, "<div><h1>{{l10n.hello}} {{h1}}</h1><h2>{{h2}}</h2></div>")
      |> Map.put(:locales, [
        %{"code" => "es_ES", "params" => %{"hello" => "Hola"}},
        %{"code" => "en_US", "params" => %{"hello" => "Hello"}},
      ])

    template = fixture(:template, attrs)
    conn = post conn, template_path(conn, :render, template), %{"h1" => "world"}
    assert %{"type" => "locale_not_found"} == json_response(conn, 404)
  end
end

defmodule Man.Web.TemplateControllerTest do
  use Man.Web.ConnCase, async: true
  alias Man.Templates.Template
  alias Man.FixturesFactory

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

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), raw_conn: conn}
  end

  test "lists and filters all entries on index", %{conn: conn} do
    assert [] ==
      conn
      |> get(template_path(conn, :index))
      |> json_response(200)
      |> Map.get("data")

    %Template{id: id1} = FixturesFactory.create(:template)
    %Template{id: id2} = FixturesFactory.create(:template, title: "other title", labels: ["label/one", "label/two"])

    assert [%{"id" => ^id1}, %{"id" => ^id2}] =
      conn
      |> get(template_path(conn, :index))
      |> json_response(200)
      |> Map.get("data")

    # Filter by title
    assert [%{"id" => ^id1}] =
      conn
      |> get(template_path(conn, :index), %{"title" => "some"})
      |> json_response(200)
      |> Map.get("data")

    # Filter by label
    assert [%{"id" => ^id2}] =
      conn
      |> get(template_path(conn, :index), %{"labels" => "label/one"})
      |> json_response(200)
      |> Map.get("data")
  end

  test "paginates entries on index", %{conn: conn} do
    %Template{id: id1} = FixturesFactory.create(:template, labels: ["label/one", "label/two"])
    %Template{id: id2} = FixturesFactory.create(:template, labels: ["label/one", "label/two"])
    %Template{id: id3} = FixturesFactory.create(:template, labels: ["label/one", "label/two"])
    %Template{id: id4} = FixturesFactory.create(:template, labels: ["label/one", "label/two"])
    %Template{id: id5} = FixturesFactory.create(:template, labels: ["label/one", "label/two"])

    assert [%{"id" => ^id1}] =
      conn
      |> get(template_path(conn, :index), %{"limit" => 1})
      |> json_response(200)
      |> Map.get("data")

    assert [%{"id" => ^id3}, %{"id" => ^id4}] =
      conn
      |> get(template_path(conn, :index), %{"limit" => 2, "starting_after" => id2})
      |> json_response(200)
      |> Map.get("data")

    assert [%{"id" => ^id3}, %{"id" => ^id4}] =
      conn
      |> get(template_path(conn, :index), %{"limit" => 2, "ending_before" => id5})
      |> json_response(200)
      |> Map.get("data")

    assert [%{"id" => ^id1}] =
      conn
      |> get(template_path(conn, :index), %{"limit" => 1})
      |> json_response(200)
      |> Map.get("data")
  end

  test "creates template and renders template when data is valid", %{conn: conn} do
    fixture = FixturesFactory.build(:template)

    assert %{"id" => id} =
      conn
      |> post(template_path(conn, :create), fixture)
      |> json_response(201)
      |> Map.get("data")

    assert %{
      "id" => ^id,
      "body" => "some body",
      "validation_schema" => %{},
      "type" => "template",
      "description" => nil,
      "labels" => [],
      "locales" => [],
      "syntax" => "mustache",
      "title" => "some title"
    } =
      conn
      |> get(template_path(conn, :show, id))
      |> json_response(200)
      |> Map.get("data")
  end

  test "does not create template and renders errors when data is invalid", %{conn: conn} do
    fixture = FixturesFactory.build(:template, @invalid_attrs)

    conn = post(conn, template_path(conn, :create), fixture)

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
    fixture = FixturesFactory.build(:template, locales: [
      %{"code" => "en_US", "params" => %{}},
      %{"code" => "en_US", "params" => %{}},
    ])

    conn = post(conn, template_path(conn, :create), fixture)

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
    %Template{id: id} = template = FixturesFactory.create(:template)
    update_attrs = FixturesFactory.build(:template, @update_attrs)

    assert %{"id" => ^id} =
      conn
      |> patch(template_path(conn, :update, template), update_attrs)
      |> json_response(200)
      |> Map.get("data")

    assert %{
      "id" => ^id,
      "body" => "some updated body",
      "validation_schema" => %{},
      "type" => "template",
      "description" => nil,
      "labels" => [],
      "locales" => [],
      "syntax" => "mustache",
      "title" => "some title"
    } =
      conn
      |> get(template_path(conn, :show, id))
      |> json_response(200)
      |> Map.get("data")
  end

  test "does not update chosen template and renders errors when data is invalid", %{conn: conn} do
    template = FixturesFactory.create(:template)
    invalid_attrs = FixturesFactory.build(:template, @invalid_attrs)
    conn = patch(conn, template_path(conn, :update, template), invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "replace chosen template and renders template when data is valid", %{conn: conn} do
    %Template{id: id} = template = FixturesFactory.create(:template, description: "Some content")
    replace_attrs = FixturesFactory.build(:template, @replace_attrs)

    assert %{"id" => ^id} =
      conn
      |> put(template_path(conn, :replace, template), replace_attrs)
      |> json_response(200)
      |> Map.get("data")

    assert %{
      "id" => ^id,
      "body" => "some replaced body",
      "validation_schema" => %{},
      "type" => "template",
      "description" => nil,
      "labels" => [],
      "locales" => [],
      "syntax" => "mustache",
      "title" => "some replaced title"
    } =
      conn
      |> get(template_path(conn, :show, id))
      |> json_response(200)
      |> Map.get("data")
  end

  test "does not replace chosen template and renders errors when data is invalid", %{conn: conn} do
    template = FixturesFactory.create(:template)
    invalid_attrs = FixturesFactory.build(:template, @invalid_attrs)

    assert %{} !=
      conn
      |> put(template_path(conn, :replace, template), invalid_attrs)
      |> json_response(422)
      |> Map.get("errors")
  end

  test "deletes chosen template", %{conn: conn} do
    template = FixturesFactory.create(:template)

    conn = delete(conn, template_path(conn, :delete, template))
    assert response(conn, 204)

    resp = get(conn, template_path(conn, :show, template))
    assert resp.status == 404
    assert resp.state == :sent
  end

  describe "renders mustache templates" do
    test "renders mustache templates in json format", %{conn: conn} do
      template = FixturesFactory.create(:template, body: "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
      conn = post(conn, template_path(conn, :render, template), %{"h1" => "some data", "h2" => "another data"})
      assert %{"body" => "<div><h1>some data</h1><h2>another data</h2></div>"} == json_response(conn, 200)
    end

    test "renders mustache templates in html format", %{raw_conn: conn} do
      template = FixturesFactory.create(:template, body: "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
      req_attrs = %{"h1" => "some data", "h2" => "another data", "format" => "text/html"}
      conn = post(conn, template_path(conn, :render, template), req_attrs)
      assert "<div><h1>some data</h1><h2>another data</h2></div>" == html_response(conn, 200)
    end

    test "renders mustache templates in PDF format", %{raw_conn: conn} do
      template = FixturesFactory.create(:template, body: "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
      req_attrs = %{"h1" => "some data", "h2" => "another data", "format" => "application/pdf"}
      conn = post(conn, template_path(conn, :render, template), req_attrs)
      assert <<37, 80, 68, 70, 45, 49, 46, 52, 10, _rest::binary>> = response(conn, 200)
    end

    test "renders mustache templates in PDF format set in Accept header", %{raw_conn: conn} do
      template = FixturesFactory.create(:template, body: "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
      req_attrs = %{"h1" => "some data", "h2" => "another data"}

      conn =
        conn
        |> put_req_header("accept", "application/pdf")
        |> post(template_path(conn, :render, template), req_attrs)

      assert <<37, 80, 68, 70, 45, 49, 46, 52, 10, _rest::binary>> = response(conn, 200)
    end
  end

  describe "renders markdown templates" do
    test "in json format", %{conn: conn} do
      body = """
        # Hello
        world
      """
      template = FixturesFactory.create(:template, syntax: "markdown", body: body)
      conn = post(conn, template_path(conn, :render, template), %{})
      assert %{"body" => "<p>  # Hello\n  world</p>\n"} == json_response(conn, 200)
    end

    test "in html format", %{raw_conn: conn} do
      body = """
        # Hello
        world
      """
      template = FixturesFactory.create(:template, syntax: "markdown", body: body)
      req_attrs = %{"format" => "text/html"}
      conn = post(conn, template_path(conn, :render, template), req_attrs)
      assert "<p>  # Hello\n  world</p>\n" == html_response(conn, 200)
    end
  end

  describe "renders iex templates" do
    test "in json format", %{conn: conn} do
      body = "<div><h1><%= @h1 %></h1><h2><%= @h2 %></h2></div>"
      template = FixturesFactory.create(:template, syntax: "iex", body: body)
      conn = post(conn, template_path(conn, :render, template), %{"h1" => "some data", "h2" => "another data"})
      assert %{"body" => "<div><h1>some data</h1><h2>another data</h2></div>"} == json_response(conn, 200)
    end

    test "in html format", %{raw_conn: conn} do
      body = "<div><h1><%= @h1 %></h1><h2><%= @h2 %></h2></div>"
      template = FixturesFactory.create(:template, syntax: "iex", body: body)
      req_attrs = %{"h1" => "some data", "h2" => "another data", "format" => "text/html"}
      conn = post(conn, template_path(conn, :render, template), req_attrs)
      assert "<div><h1>some data</h1><h2>another data</h2></div>" == html_response(conn, 200)
    end

    test "with missing attributes", %{conn: conn} do
      body = "<div><h1><%= @h1 %></h1><h2><%= @h2 %></h2></div>"
      template = FixturesFactory.create(:template, syntax: "iex", body: body)
      conn = post(conn, template_path(conn, :render, template), %{})
      assert %{"body" => @empty_rendered_template} == json_response(conn, 200)
    end
  end

  test "renders templates with missing attributes", %{conn: conn} do
    template = FixturesFactory.create(:template, body: "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
    conn = post(conn, template_path(conn, :render, template), %{})
    assert %{"body" => @empty_rendered_template} == json_response(conn, 200)
  end

  test "takes format from Accept header", %{raw_conn: conn} do
    template = FixturesFactory.create(:template)
    req_attrs = %{"h1" => "some data", "h2" => "another data", "format" => "text/html"}

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> post(template_path(conn, :render, template), req_attrs)

    assert %{"body" => "some body"} == json_response(conn, 200)
  end

  test "returns error on unsupported format", %{raw_conn: conn} do
    template = FixturesFactory.create(:template, body: "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
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
    body = "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>"
    template = FixturesFactory.create(:template, body: body, validation_schema: @validation_schema)
    conn = post(conn, template_path(conn, :render, template), %{"h2" => "another data"})
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
    body = "<div><h1>{{l10n.hello}} {{h1}}</h1><h2>{{h2}}</h2></div>"
    locales = [%{"code" => "es_ES", "params" => %{"hello" => "Hola"}}]
    template = FixturesFactory.create(:template, body: body, locales: locales)
    conn =
      conn
      |> put_req_header("accept-language", "es_ES")
      |> post(template_path(conn, :render, template), %{"h1" => "world", "locale" => "en_US"})

    assert %{"body" => "<div><h1>Hola world</h1><h2></h2></div>"} == json_response(conn, 200)
  end

  test "localizes templates with default locale", %{conn: conn} do
    body = "<div><h1>{{l10n.hello}} {{h1}}</h1><h2>{{h2}}</h2></div>"
    locales = [%{"code" => "es_ES", "params" => %{"hello" => "Hola"}}]
    template = FixturesFactory.create(:template, body: body, locales: locales)
    conn = post(conn, template_path(conn, :render, template), %{"h1" => "world"})
    assert %{"body" => "<div><h1>Hola world</h1><h2></h2></div>"} == json_response(conn, 200)
  end

  test "localizes templates with multiple locales", %{conn: conn} do
    body = "<div><h1>{{l10n.hello}} {{h1}}</h1><h2>{{h2}}</h2></div>"
    locales = [
      %{"code" => "es_ES", "params" => %{"hello" => "Hola"}},
      %{"code" => "en_US", "params" => %{"hello" => "Hello"}},
    ]

    template = FixturesFactory.create(:template, body: body, locales: locales)
    conn = post(conn, template_path(conn, :render, template), %{"h1" => "world", "locale" => "en_US"})
    assert %{"body" => "<div><h1>Hello world</h1><h2></h2></div>"} == json_response(conn, 200)
  end

  test "returns error when locale is not set", %{conn: conn} do
    body = "<div><h1>{{l10n.hello}} {{h1}}</h1><h2>{{h2}}</h2></div>"
    locales = [
      %{"code" => "es_ES", "params" => %{"hello" => "Hola"}},
      %{"code" => "en_US", "params" => %{"hello" => "Hello"}},
    ]

    template = FixturesFactory.create(:template, body: body, locales: locales)
    conn = post(conn, template_path(conn, :render, template), %{"h1" => "world"})
    assert %{"type" => "locale_not_found"} == json_response(conn, 404)
  end

  test "may cache PDF output", %{raw_conn: conn} do
    Application.put_env(:man, :cache_pdf_output, true)
    on_exit(fn ->
      Application.put_env(:man, :cache_pdf_output, false)
    end)

    template = FixturesFactory.create(:template, body: "<div><h1>{{h1}}</h1><h2>{{h2}}</h2></div>")
    req_attrs = %{"h1" => "some data", "h2" => "another data"}

    conn = put_req_header(conn, "accept", "application/pdf")

    {time1, result1} = :timer.tc(fn -> post(conn, template_path(conn, :render, template), req_attrs) end)
    {time2, result2} = :timer.tc(fn -> post(conn, template_path(conn, :render, template), req_attrs) end)
    {time3, _result} = :timer.tc(fn -> post(conn, template_path(conn, :render, template), req_attrs) end)

    # More than in 20 times faster (~600x on my laptop, ~50x on Travis-CI)
    assert (time1/time2) > 20
    assert (time1/time3) > 20

    assert <<37, 80, 68, 70, 45, 49, 46, 52, 10, _rest::binary>> = response(result1, 200)
    assert <<37, 80, 68, 70, 45, 49, 46, 52, 10, _rest::binary>> = response(result2, 200)
  end
end

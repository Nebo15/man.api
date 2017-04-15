defmodule Man.TemplatesTest do
  use Man.DataCase
  alias Man.Templates.API
  alias Man.Templates.Template

  @create_attrs %{body: "some body", validation_schema: %{}, title: "some title"}
  @update_attrs %{body: "some updated body", validation_schema: %{}, title: "some title"}
  @invalid_attrs %{body: nil, validation_schema: nil, title: nil, labels: [1, 2, 3]}
  @template_body "<div><h1><%= @h1 %></h1><h2><%= @h2 %></h2></div>"
  @all_render_attrs %{"h1" => "some data", "h2" => "another data"}
  @h1_valid_render_attr %{"h1" => "some data"}
  @h1_invalid_render_attr %{"h1" => 111}
  @full_rendered_template "<div><h1>some data</h1><h2>another data</h2></div>"
  @partially_rendered_template "<div><h1>some data</h1><h2></h2></div>"
  @empty_rendered_template "<div><h1></h1><h2></h2></div>"
  @validation_schema %{
    "type" => "object",
    "required" => [
      "h1"
    ],
    "properties" => %{
      "h1" => %{
        "type" => "string"
      }
    }
  }

  def fixture(:template, attrs \\ @create_attrs) do
    {:ok, template} = API.create_template(attrs)
    template
  end

  test "list_templates/1 returns all templates" do
    template = fixture(:template)
    assert API.list_templates() == [template]
  end

  test "list_labels/1 returns all labels" do
    fixture(:template, Map.put(@create_attrs, :labels, ["a", "b", "c"]))
    fixture(:template, Map.put(@create_attrs, :labels, ["a", "d", "e"]))
    assert API.list_labels() == ["b", "e", "a", "c", "d"]
  end

  test "get_template! returns the template with given id" do
    template = fixture(:template)
    assert {:ok, ^template} = API.get_template(template.id)
  end

  test "create_template/1 with valid data creates a template" do
    assert {:ok, %Template{} = template} = API.create_template(@create_attrs)
    assert template.body == "some body"
    assert template.validation_schema == %{}
  end

  test "create_template/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = API.create_template(@invalid_attrs)
  end

  test "update_template/2 with valid data updates the template" do
    template = fixture(:template)
    assert {:ok, template} = API.update_template(template, @update_attrs)
    assert %Template{} = template
    assert template.body == "some updated body"
    assert template.validation_schema == %{}
  end

  test "update_template/2 with invalid data returns error changeset" do
    template = fixture(:template)
    assert {:error, %Ecto.Changeset{}} = API.update_template(template, @invalid_attrs)
    assert {:ok, ^template} = API.get_template(template.id)
  end

  test "delete_template/1 deletes the template" do
    template = fixture(:template)
    assert {:ok, %Template{}} = API.delete_template(template)
    assert {:error, :not_found} = API.get_template(template.id)
  end

  test "change_template/1 returns a template changeset" do
    template = fixture(:template)
    assert %Ecto.Changeset{} = API.change_template(template)
  end

  # test "render_template/2 renders template with all parameters" do
  #   template = fixture(:template, %{body: @template_body, validation_schema: %{}})
  #   assert {:ok, @full_rendered_template} = API.render_template(template, @all_render_attrs)
  # end

  # test "render_template/2 renders template without all parameters" do
  #   template = fixture(:template, %{body: @template_body, validation_schema: %{}})
  #   assert {:ok, @partially_rendered_template} = API.render_template(template, @h1_valid_render_attr)
  # end

  # test "render_template/2 renders template without parameters" do
  #   template = fixture(:template, %{body: @template_body, validation_schema: %{}})
  #   assert {:ok, @empty_rendered_template} = API.render_template(template, %{})
  # end

  # test "render_template/2 validates missing render parameter" do
  #   template = fixture(:template, %{body: @template_body, validation_schema: @validation_schema})
  #   assert {:error, _} = API.render_template(template, %{})
  # end

  # test "render_template/2 validates invalid render parameter" do
  #   template = fixture(:template, %{body: @template_body, validation_schema: @validation_schema})
  #   assert {:error, _} = API.render_template(template, @h1_invalid_render_attr)
  # end

  # test "render_template/2 validates valid render parameter" do
  #   template = fixture(:template, %{body: @template_body, validation_schema: @validation_schema})
  #   assert {:ok, @partially_rendered_template} = API.render_template(template, @h1_valid_render_attr)
  # end
end

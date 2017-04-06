defmodule Printout.TemplateAPITest do
  use Printout.DataCase

  alias Printout.TemplateAPI
  alias Printout.TemplateAPI.Template

  @create_attrs %{body: "some body", json_schema: %{}}
  @update_attrs %{body: "some updated body", json_schema: %{}}
  @invalid_attrs %{body: nil, json_schema: nil}
  @template_body "<div><h1><%= @h1 %></h1><h2><%= @h2 %></h2></div>"
  @all_print_attrs %{"h1" => "some data", "h2" => "another data"}
  @h1_valid_print_attr %{"h1" => "some data"}
  @h1_invalid_print_attr %{"h1" => 111}
  @full_rendered_template "<div><h1>some data</h1><h2>another data</h2></div>"
  @partially_rendered_template "<div><h1>some data</h1><h2></h2></div>"
  @empty_rendered_template "<div><h1></h1><h2></h2></div>"
  @json_schema %{
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
    {:ok, template} = TemplateAPI.create_template(attrs)
    template
  end

  test "list_templates/1 returns all templates" do
    template = fixture(:template)
    assert TemplateAPI.list_templates() == [template]
  end

  test "get_template! returns the template with given id" do
    template = fixture(:template)
    assert TemplateAPI.get_template!(template.id) == template
  end

  test "create_template/1 with valid data creates a template" do
    assert {:ok, %Template{} = template} = TemplateAPI.create_template(@create_attrs)
    assert template.body == "some body"
    assert template.json_schema == %{}
  end

  test "create_template/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = TemplateAPI.create_template(@invalid_attrs)
  end

  test "update_template/2 with valid data updates the template" do
    template = fixture(:template)
    assert {:ok, template} = TemplateAPI.update_template(template, @update_attrs)
    assert %Template{} = template
    assert template.body == "some updated body"
    assert template.json_schema == %{}
  end

  test "update_template/2 with invalid data returns error changeset" do
    template = fixture(:template)
    assert {:error, %Ecto.Changeset{}} = TemplateAPI.update_template(template, @invalid_attrs)
    assert template == TemplateAPI.get_template!(template.id)
  end

  test "delete_template/1 deletes the template" do
    template = fixture(:template)
    assert {:ok, %Template{}} = TemplateAPI.delete_template(template)
    assert_raise Ecto.NoResultsError, fn -> TemplateAPI.get_template!(template.id) end
  end

  test "change_template/1 returns a template changeset" do
    template = fixture(:template)
    assert %Ecto.Changeset{} = TemplateAPI.change_template(template)
  end

  test "print_template/2 prints template with all parameters" do
    template = fixture(:template, %{body: @template_body, json_schema: %{}})
    assert {:ok, @full_rendered_template} = TemplateAPI.print_template(template, @all_print_attrs)
  end

  test "print_template/2 prints template without all parameters" do
    template = fixture(:template, %{body: @template_body, json_schema: %{}})
    assert {:ok, @partially_rendered_template} = TemplateAPI.print_template(template, @h1_valid_print_attr)
  end

  test "print_template/2 prints template without parameters" do
    template = fixture(:template, %{body: @template_body, json_schema: %{}})
    assert {:ok, @empty_rendered_template} = TemplateAPI.print_template(template, %{})
  end

  test "print_template/2 validates missing print parameter" do
    template = fixture(:template, %{body: @template_body, json_schema: @json_schema})
    assert {:error, _} = TemplateAPI.print_template(template, %{})
  end

  test "print_template/2 validates invalid print parameter" do
    template = fixture(:template, %{body: @template_body, json_schema: @json_schema})
    assert {:error, _} = TemplateAPI.print_template(template, @h1_invalid_print_attr)
  end

  test "print_template/2 validates valid print parameter" do
    template = fixture(:template, %{body: @template_body, json_schema: @json_schema})
    assert {:ok, @partially_rendered_template} = TemplateAPI.print_template(template, @h1_valid_print_attr)
  end
end

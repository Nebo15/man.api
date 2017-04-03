defmodule EhealthPrintout.TemplateAPITest do
  use EhealthPrintout.DataCase

  alias EhealthPrintout.TemplateAPI
  alias EhealthPrintout.TemplateAPI.Template

  @create_attrs %{body: "some body", json_schema: %{}}
  @update_attrs %{body: "some updated body", json_schema: %{}}
  @invalid_attrs %{body: nil, json_schema: nil}

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
end

defmodule Man.Templates.APITest do
  use Man.DataCase
  alias Man.Templates.API
  alias Man.Templates.Template

  @create_attrs %{body: "some body", validation_schema: %{}, title: "some title"}
  @update_attrs %{body: "some updated body", validation_schema: %{}, title: "some title"}
  @invalid_attrs %{body: nil, validation_schema: nil, title: nil, labels: [1, 2, 3]}

  def fixture(:template, attrs \\ @create_attrs) do
    {:ok, template} = API.create_template(attrs)
    template
  end

  test "list_templates/1 returns all templates" do
    template = fixture(:template)
    assert {[^template], _paging} = API.list_templates()
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

  test "replace_template/2 with valid data updates the template" do
    template = fixture(:template)
    assert {:ok, template} = API.replace_template(template.id, @update_attrs)
    assert %Template{} = template
    assert template.body == "some updated body"
    assert template.validation_schema == %{}
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
end

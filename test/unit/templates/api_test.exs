defmodule Man.Templates.APITest do
  use Man.DataCase, async: true
  alias Man.Templates.API
  alias Man.Templates.Template
  alias Man.FixturesFactory

  @create_attrs %{body: "some body", validation_schema: %{}, title: "some title"}
  @update_attrs %{body: "some updated body", validation_schema: %{}, title: "some title"}
  @invalid_attrs %{body: nil, validation_schema: nil, title: nil, labels: [1, 2, 3]}

  describe "list_templates/1" do
    test "returns all templates" do
      assert {[], _paging} = API.list_templates()
      template = FixturesFactory.create(:template)
      assert {[^template], _paging} = API.list_templates()
    end

    test "filters by title" do
      template = FixturesFactory.create(:template)
      assert {[^template], _paging} = API.list_templates()
    end

    test "filters by labels" do
      template = FixturesFactory.create(:template)
      assert {[^template], _paging} = API.list_templates()
    end

    test "paginates results" do
      template = FixturesFactory.create(:template)
      assert {[^template], _paging} = API.list_templates()
    end
  end

  test "list_labels/1 returns all labels" do
    FixturesFactory.create(:template, labels: ["a", "b", "c"])
    FixturesFactory.create(:template, labels: ["a", "d", "e"])
    assert ["b", "e", "a", "c", "d"] = API.list_labels()
  end

  describe "get_template/1" do
    test "returns the template with given id" do
      template = FixturesFactory.create(:template)
      assert {:ok, ^template} = API.get_template(template.id)
    end

    test "with invalid template id returns error" do
      assert {:error, :not_found} = API.get_template(1)
    end
  end

  describe "create_template/1" do
    test "with valid data creates a template" do
      assert {:ok, %Template{} = template} = API.create_template(@create_attrs)
      assert template.body == "some body"
      assert template.validation_schema == %{}
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = API.create_template(@invalid_attrs)
    end
  end

  describe "update_template/2" do
    test "with valid data updates the template" do
      template = FixturesFactory.create(:template)
      assert {:ok, %Template{} = template} = API.update_template(template, @update_attrs)
      assert template.body == "some updated body"
      assert template.validation_schema == %{}
    end

    test "with invalid data returns error changeset" do
      template = FixturesFactory.create(:template)
      assert {:error, %Ecto.Changeset{}} = API.update_template(template, @invalid_attrs)
      assert {:ok, ^template} = API.get_template(template.id)
    end
  end

  test "replace_template/2 with valid data updates the template" do
    template = FixturesFactory.create(:template)
    assert {:ok, template} = API.replace_template(template.id, @update_attrs)
    assert %Template{} = template
    assert template.body == "some updated body"
    assert template.validation_schema == %{}
  end

  test "delete_template/1 deletes the template" do
    template = FixturesFactory.create(:template)
    assert {:ok, %Template{}} = API.delete_template(template)
    assert {:error, :not_found} = API.get_template(template.id)
  end

  test "change_template/1 returns a template changeset" do
    template = FixturesFactory.create(:template)
    assert %Ecto.Changeset{} = API.change_template(template)
  end
end

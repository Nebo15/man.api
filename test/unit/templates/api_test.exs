defmodule Man.Templates.APITest do
  use Man.DataCase, async: true
  alias Man.Templates.API
  alias Man.Templates.Template
  alias Man.FixturesFactory
  alias Ecto.Paging
  alias Ecto.Paging.Cursors

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
      template1 = FixturesFactory.create(:template)
      template2 = FixturesFactory.create(:template, title: "other title")

      assert {[^template1, ^template2], _paging} = API.list_templates(%{"title" => nil})
      assert {[], _paging} = API.list_templates(%{"title" => "unknown title"})
      assert {[^template1], _paging} = API.list_templates(%{"title" => "some"})
      assert {[^template2], _paging} = API.list_templates(%{"title" => "other"})
    end

    test "filters by labels" do
      template1 = FixturesFactory.create(:template)
      template2 = FixturesFactory.create(:template, labels: ["label/one", "label/two"])
      template3 = FixturesFactory.create(:template, labels: ["label/one", "label/three"])

      assert {[^template1, ^template2, ^template3], _paging} = API.list_templates(%{"labels" => nil})
      assert {[], _paging} = API.list_templates(%{"labels" => "unknown label"})
      assert {[^template2], _paging} = API.list_templates(%{"labels" => "label/two"})
      assert {[^template2, ^template3], _paging} = API.list_templates(%{"labels" => "label/one"})
    end

    test "paginates results" do
      template1 = FixturesFactory.create(:template)
      template2 = FixturesFactory.create(:template)
      template3 = FixturesFactory.create(:template)
      template4 = FixturesFactory.create(:template)
      template5 = FixturesFactory.create(:template)

      assert {[^template1], _paging} =
        API.list_templates(%{}, %Paging{limit: 1})
      assert {[^template1, ^template2], _paging} =
        API.list_templates(%{}, %Paging{limit: 2})
      assert {[^template3, ^template4], _paging} =
        API.list_templates(%{}, %Paging{limit: 2, cursors: %Cursors{starting_after: template2.id}})
      assert {[^template3, ^template4], _paging} =
        API.list_templates(%{}, %Paging{limit: 2, cursors: %Cursors{ending_before: template5.id}})
    end

    test "paginates with filters" do
      FixturesFactory.create(:template, labels: ["label/one", "label/two"], title: "title one")
      FixturesFactory.create(:template, labels: ["label/one"], title: "title two")
      template3 = FixturesFactory.create(:template, labels: ["label/one", "label/two"], title: "title three")
      template4 = FixturesFactory.create(:template, labels: ["label/one"], title: "title four")
      template5 = FixturesFactory.create(:template, labels: ["label/one"], title: "title five")

      assert {[^template3, ^template4], _paging} =
        API.list_templates(%{"title" => "title"}, %Paging{limit: 2, cursors: %Cursors{ending_before: template5.id}})

      assert {[], _paging} =
        API.list_templates(%{"title" => "five"}, %Paging{limit: 2, cursors: %Cursors{ending_before: template5.id}})

      assert {[^template5], _paging} =
        API.list_templates(%{"title" => "five"}, %Paging{limit: 2, cursors: %Cursors{starting_after: template4.id}})

      paging = %Paging{limit: 2, cursors: %Cursors{ending_before: template5.id}}
      assert {[^template3, ^template4], _paging} =
        API.list_templates(%{"labels" => "label/one"}, paging)

      paging = %Paging{limit: 1, cursors: %Cursors{ending_before: template5.id}}
      assert {[^template3], _paging} =
        API.list_templates(%{"labels" => "label/two"}, paging)
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

  describe "replace_template/2" do
    test "with valid data updates the template" do
      template = FixturesFactory.create(:template)
      assert {:ok, %Template{} = template} = API.replace_template(template.id, @update_attrs)
      assert template.body == "some updated body"
      assert template.validation_schema == %{}
    end

    test "with not found template" do
      id = 1
      attrs =
        :template
        |> FixturesFactory.build(@update_attrs)
        |> Map.put(:id, id)

      assert {:ok, %Template{} = template} = API.replace_template(id, attrs)
      assert template.body == "some updated body"
      assert template.validation_schema == %{}
    end
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

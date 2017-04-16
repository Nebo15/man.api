defmodule Man.FixturesFactory do
  @moduledoc """
  This module provides simple factory to generate fixtures in tests.
  """
  alias Man.Templates.API

  def create(schema, attrs \\ %{})

  def create(schema, attrs) when is_list(attrs),
    do: create(schema, Enum.into(attrs, %{}))

  def create(:template, attrs) do
    {:ok, template} =
      %{
        body: "some body",
        validation_schema: %{},
        title: "some title"
      }
      |> Map.merge(attrs)
      |> API.create_template()

    template
  end
end

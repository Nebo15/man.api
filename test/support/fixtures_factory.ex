defmodule Man.FixturesFactory do
  @moduledoc """
  This module provides simple factory to generate fixtures in tests.
  """
  alias Man.Templates.API

  def create(:template, attrs \\ %{}) do
    {:ok, template} =
      :template
      |> build(attrs)
      |> API.create_template()

    template
  end

  def build(fixture, attrs \\ %{})

  def build(fixture, attrs) when is_list(attrs), do: build(fixture, Enum.into(attrs, %{}))

  def build(:template, attrs) do
    %{
      body: "some body",
      validation_schema: %{},
      title: "some title"
    }
    |> Map.merge(attrs)
  end
end

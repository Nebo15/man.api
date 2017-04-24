defmodule Man.Templates.Template do
  @moduledoc false
  use Ecto.Schema

  schema "templates" do
    field :title, :string
    field :description, :string
    field :syntax, :string, default: "mustache"
    field :body, :string, default: ""
    field :validation_schema, :map
    field :labels, {:array, :string}, default: []

    embeds_many :locales, Locale, primary_key: false do
      field :code, :string
      field :params, :map
    end

    timestamps()
  end
end

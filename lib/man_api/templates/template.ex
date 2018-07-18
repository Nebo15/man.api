defmodule Man.Templates.Template do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "templates" do
    field(:title, :string)
    field(:description, :string)
    field(:syntax, :string, default: "mustache")
    field(:body, :string, default: "")
    field(:validation_schema, :map)
    field(:labels, {:array, :string}, default: [])

    embeds_many :locales, Locale, primary_key: false do
      field(:code, :string)
      field(:params, :map)
    end

    timestamps()
  end

  def changeset(%__MODULE__{} = template, attrs) do
    template
    |> cast(attrs, ~w(title description syntax body validation_schema)a)
    |> cast_embed(:locales, with: &locale_changeset/2)
  end

  def locale_changeset(%Man.Templates.Template.Locale{} = locale, attrs) do
    cast(locale, attrs, ~w(code params)a)
  end
end

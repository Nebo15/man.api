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
    embeds_many(:locales, Man.Templates.Template.Locale, on_replace: :delete)

    timestamps()
  end

  def changeset(%__MODULE__{} = template, attrs) do
    template
    |> cast(attrs, ~w(title description syntax body validation_schema)a)
    |> cast_embed(:locales)
  end
end

defmodule Man.Templates.Template.Locale do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:code, :string)
    field(:params, :map)
  end

  def changeset(%__MODULE__{} = locale, attrs) do
    cast(locale, attrs, ~w(code params)a)
  end
end

defmodule Man.Repo.Migrations.AddChainValidationTemplate do
  use Ecto.Migration
  alias Man.Repo
  alias Man.Templates.Template
  import Ecto.Changeset

  def locale_changeset(%Man.Templates.Template.Locale{} = locale, attrs) do
    cast(locale, attrs, ~w(code params)a)
  end

  def change do
    result =
      case Repo.get_by(Template, %{:title => "Chain validation"}) do
        nil -> %Template{}
        template -> template
      end

    result
    |> cast(
      %{
        "title" => "Chain validation",
        "description" => "Notifcation email",
        "syntax" => "mustache",
        "locales" => [
          %{
            "code" => "uk_UA"
          }
        ],
        "body" => ""
      },
      ~w(id title description syntax body)a
    )
    |> cast_embed(:locales, with: &locale_changeset/2)
    |> Repo.insert_or_update!()
  end
end

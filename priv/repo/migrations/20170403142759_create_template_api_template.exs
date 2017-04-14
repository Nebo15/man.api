defmodule Man.Repo.Migrations.Create.Templates.Template do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :title, :string, null: false, length: 255
      add :description, :string, length: 510
      add :syntax, :string, default: "mustache"
      add :body, :string, default: ""
      add :locales, {:array, :map}
      add :labels, {:array, :string}
      add :validation_schema, :map

      timestamps(type: :utc_datetime)
    end
  end
end

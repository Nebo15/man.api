defmodule Man.Repo.Migrations.CreateLabelsIndex do
  use Ecto.Migration

  def change do
    create index(:templates, :labels, using: :gin)
  end
end

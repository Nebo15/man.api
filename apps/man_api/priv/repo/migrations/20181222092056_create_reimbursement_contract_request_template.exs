defmodule Man.Repo.Migrations.CreateReimbursementContractRequestTemplate do
  use Ecto.Migration
  import Ecto.Changeset

  alias Man.Templates.Template
  alias Man.Repo

  def change do
    %Template{}
    |> cast(
      %{
        "title" => "RCRPF",
        "description" => "Reimbursement contract request printout form",
        "syntax" => "iex",
        "locales" => [%{"code" => "uk_UA", "params" => %{}}],
        "body" =>
          "<!DOCTYPE html><html>Reimbursement contract request printout form</html>"
      },
      ~w(id title description syntax body)a
    )
    |> cast_embed(:locales)
    |> Repo.insert!()
  end
end

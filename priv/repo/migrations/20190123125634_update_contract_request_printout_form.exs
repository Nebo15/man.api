defmodule Man.Repo.Migrations.UpdateContractRequestPrintoutForm do
  use Ecto.Migration

  import Ecto.Changeset
  import Ecto.Query

  alias Man.Templates.Template
  alias Man.Repo

  def change do
    template_body = File.read!(Application.app_dir(:man_api, "priv/static/RCRPF.html.eex"))

    Template
    |> where([t], t.title == "RCRPF")
    |> Repo.one!()
    |> cast(%{body: template_body}, ~w(body)a)
    |> Repo.update!()
  end
end

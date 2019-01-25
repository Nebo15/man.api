defmodule Man.Repo.Migrations.CrfAppendix do
  @moduledoc false

  use Ecto.Migration

  alias Man.Repo
  alias Man.Templates.Template
  import Ecto.Changeset
  import Ecto.Query

  def change do
    crf_body = File.read!(Application.app_dir(:man_api, "priv/static/CRPF_appendix.html.eex"))

    template =
      Template
      |> where([t], t.title == "CRPF appendix")
      |> Repo.one!()

    template
    |> cast(%{"body" => crf_body}, ~w(body)a)
    |> Repo.update!()
  end
end

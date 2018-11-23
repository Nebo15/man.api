defmodule Man.Repo.Migrations.CrfAppendix do
  use Ecto.Migration

  alias Man.Repo
  alias Man.Templates.Template
  import Ecto.Changeset

  def change do
    crf_body = File.read!(Application.app_dir(:man_api, "priv/static"), "/CRPF_appendix.html.eex")

    %Template{}
    |> cast(
      %{
        "title" => "CRPF appendix",
        "description" => "CRPF appendix",
        "syntax" => "iex",
        "locales" => [%{"code" => "uk_UA", "params" => %{}}],
        "body" => crf_body
      },
      ~w(id title description syntax body)a
    )
    |> cast_embed(:locales)
    |> Repo.insert!()
  end
end

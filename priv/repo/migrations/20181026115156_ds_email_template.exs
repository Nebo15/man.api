defmodule Man.Repo.Migrations.DsEmailTemplate do
  use Ecto.Migration

  alias Man.Repo
  alias Man.Templates.Template
  import Ecto.Changeset

  def change do
    %Template{}
    |> cast(
      %{
        "title" => "DS.API.Email",
        "description" => "Email invalid sign content info",
        "syntax" => "iex",
        "locales" => [%{"code" => "uk_UA", "params" => %{}}],
        "body" =>
          "<!DOCTYPE html><html>Invalid signed content with id was marked as valid: <%= invalid_content_id %></html>"
      },
      ~w(id title description syntax body)a
    )
    |> cast_embed(:locales)
    |> Repo.insert!()
  end
end

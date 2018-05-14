defmodule Man.Repo.Migrations.CreateContractRequestTemplate do
  @moduledoc false

  use Ecto.Migration
  alias Man.Repo
  alias Man.Templates.Template
  import Ecto.Changeset

  def change do
    %Template{}
    |> cast(
      %{
        "title" => "CRPF",
        "description" => "Contract request printout form",
        "syntax" => "iex",
        "body" =>
          "<!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\"><head> <meta charset=\"utf-8\"> <style></style></head><body></body></html>"
      },
      ~w(id title description syntax body)a
    )
    |> Repo.insert!()
  end
end

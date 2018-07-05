defmodule Man.Repo.Migrations.SetCrpfLocale do
  @moduledoc false

  use Ecto.Migration
  alias Man.Repo

  def change do
    execute(~s(UPDATE templates SET locales = '{"{\\"code\\": \\"uk_UA\\"}"}' where title = 'CRPF'))
  end
end

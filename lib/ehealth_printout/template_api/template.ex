defmodule EhealthPrintout.TemplateAPI.Template do
  @moduledoc false
  use Ecto.Schema

  schema "templates" do
    field :body, :string
    field :json_schema, :map

    timestamps()
  end
end

defmodule Man.Web.LabelController do
  @moduledoc false
  use Man.Web, :controller
  alias Man.Templates.API

  action_fallback(Man.Web.FallbackController)

  def index(conn, _params) do
    labels = API.list_labels()
    render(conn, "index.json", labels: labels)
  end
end

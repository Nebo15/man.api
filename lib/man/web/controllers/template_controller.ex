defmodule Man.Web.TemplateController do
  @moduledoc false
  use Man.Web, :controller

  alias Man.Templates.API
  alias Man.Templates.Template

  action_fallback Man.Web.FallbackController

  def index(conn, _params) do
    templates = API.list_templates()
    render(conn, "index.json", templates: templates)
  end

  def create(conn, template_params) do
    with {:ok, %Template{} = template} <- API.create_template(template_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", template_path(conn, :show, template))
      |> render("show.json", template: template)
    end
  end

  def show(conn, %{"id" => id}) do
    template = API.get_template!(id)
    render(conn, "show.json", template: template)
  end

  def update(conn, %{"id" => id} = template_params) do
    template = API.get_template!(id)

    with {:ok, %Template{} = template} <- API.update_template(template, template_params) do
      render(conn, "show.json", template: template)
    end
  end

  def delete(conn, %{"id" => id}) do
    template = API.get_template!(id)
    with {:ok, %Template{}} <- API.delete_template(template) do
      send_resp(conn, :no_content, "")
    end
  end

  def print(conn, %{"id" => id} = template_params) do
    template = API.get_template!(id)
    with {:ok, html} <- API.print_template(template, template_params) do
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, html)
    end
  end
end

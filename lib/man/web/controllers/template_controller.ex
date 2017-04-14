defmodule Man.Web.TemplateController do
  @moduledoc false
  use Man.Web, :controller
  alias Man.Templates.API
  alias Man.Templates.Template
  alias Man.Templates.Renderer

  action_fallback Man.Web.FallbackController

  def index(conn, params) do
    conditions = Map.take(params, ["title", "labels"])
    templates = API.list_templates(conditions)
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
    with {:ok, %Template{} = template} <- API.get_template(id) do
      render(conn, "show.json", template: template)
    end
  end

  def replace(conn, %{"id" => id} = template_params) do
    with {:ok, %Template{} = template} <- API.replace_template(id, template_params) do
      render(conn, "show.json", template: template)
    end
  end

  def update(conn, %{"id" => id} = template_params) do
    with {:ok, %Template{} = template} <- API.get_template(id),
         {:ok, %Template{} = template} <- API.update_template(template, template_params) do
      render(conn, "show.json", template: template)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Template{} = template} <- API.get_template(id),
         {:ok, %Template{}} <- API.delete_template(template) do
      send_resp(conn, :no_content, "")
    end
  end

  def render(conn, %{"id" => id} = template_params) do
    with {:ok, %Template{} = template} <- API.get_template(id),
         {:ok, html} <- Renderer.render_template(template, template_params) do
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, html)
    end
  end
end

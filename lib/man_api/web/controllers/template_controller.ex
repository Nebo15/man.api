defmodule Man.Web.TemplateController do
  @moduledoc false

  use Man.Web, :controller
  alias Man.Templates.API
  alias Man.Templates.Renderer
  alias Man.Templates.Template
  alias Plug.Conn
  alias Scrivener.Page

  action_fallback(Man.Web.FallbackController)

  def index(conn, params) do
    with %Page{} = paging <- API.list_templates(params) do
      render(conn, "index.json", templates: paging.entries, paging: paging)
    end
  end

  def create(conn, %{"template" => template_params}) do
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

  def replace(conn, %{"id" => id, "template" => template_params}) do
    with {:ok, %Template{} = template} <- API.replace_template(id, template_params) do
      render(conn, "show.json", template: template)
    end
  end

  def update(conn, %{"id" => id, "template" => template_params}) do
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

  def render(conn, %{"id" => id} = render_params) do
    locale = get_header_or_param(conn, render_params, "accept-language", "locale")
    format = get_header_or_param(conn, render_params, "accept", "format")

    render_params =
      render_params
      |> Map.put("locale", locale)
      |> Map.put("format", format)

    with {:ok, %Template{} = template} <- API.get_template(id),
         {:ok, {format, output}} <- Renderer.render_template(template, render_params) do
      conn
      |> put_resp_content_type(format)
      |> send_resp(200, output)
    end
  end

  defp get_header_or_param(conn, params, header, param) do
    case Conn.get_req_header(conn, header) do
      [locale | _] ->
        locale

      [] ->
        Map.get(params, param, nil)
    end
  end
end

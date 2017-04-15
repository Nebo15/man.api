defmodule Man.Web.TemplateController do
  @moduledoc false
  use Man.Web, :controller
  alias Man.Templates.API
  alias Man.Templates.Template
  alias Man.Templates.Renderer
  alias Plug.Conn

  action_fallback Man.Web.FallbackController

  def index(conn, params) do
    conditions = Map.take(params, ["title", "labels"])
    {templates, paging} = API.list_templates(conditions)
    render(conn, "index.json", templates: templates, paging: paging)
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
    locale = get_consumer_locale(conn, template_params)
    format = get_output_format(conn, template_params)

    template_params =
      template_params
      |> Map.put("locale", locale)
      |> Map.put("format", format)

    with {:ok, %Template{} = template} <- API.get_template(id),
         {:ok, {format, html}} <- Renderer.render_template(template, template_params) do
      conn
      |> put_resp_content_type(format)
      |> send_resp(200, html)
    end
  end

  defp get_consumer_locale(_conn, %{"locale" => locale}),
    do: locale
  defp get_consumer_locale(conn, _params) do
    case Conn.get_req_header(conn, "accept-language") do
      [locale | _] -> locale
      [] -> nil
    end
  end

  defp get_output_format(_conn, %{"format" => format}),
    do: format
  defp get_output_format(conn, _params) do
    case Conn.get_req_header(conn, "accept") do
      [format | _] -> format
      [] -> nil
    end
  end
end

defmodule Man.Web.TemplateView do
  @moduledoc false
  use Man.Web, :view
  alias Man.Web.TemplateView

  def render("index.json", %{templates: templates}) do
    render_many(templates, TemplateView, "template.json")
  end

  def render("show.json", %{template: template}) do
    render_one(template, TemplateView, "template.json")
  end

  def render("template.json", %{template: template}) do
    %{
      id: template.id,
      title: template.title,
      description: template.description,
      syntax: template.syntax,
      body: template.body,
      validation_schema: template.validation_schema,
      labels: template.labels,
      locales: template.locales
    }
  end
end

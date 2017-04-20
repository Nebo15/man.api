defmodule Man.Templates.Renderer do
  @moduledoc false
  alias Man.Templates.Template
  alias Man.Templates.Template.Locale
  alias Man.Cache
  alias NExJsonSchema.Validator

  @doc """
  Renders a template.

  ## Examples

      iex> render_template(template, attrs)
      {:ok, html}

      iex> render_template(template, attrs)
      {:error, {:unsupported_format, message}}

  """
  def render_template(%Template{} = template, attrs) do
    cache_pdf? = Confex.get(:man_api, :cache_pdf_output, false)

    with :ok <- validate_attrs(template, attrs),
         {:ok, localized_attrs} <- localize_attrs(template, attrs),
         {:ok, html} <- render_html(template, localized_attrs),
      do: render_output(html, localized_attrs, cache_pdf?)
  end

  defp validate_attrs(%Template{validation_schema: nil}, _attrs),
    do: :ok
  defp validate_attrs(%Template{validation_schema: validation_schema}, attrs) do
    Validator.validate(validation_schema, attrs)
  end

  defp localize_attrs(%Template{locales: []}, %{"locale" => nil} = attrs),
    do: {:ok, attrs}
  defp localize_attrs(%Template{locales: [%Locale{code: code, params: params}]}, %{"locale" => nil} = attrs),
    do: {:ok,  attrs |> Map.put("locale", code) |> Map.put("l10n", params)}
  defp localize_attrs(%Template{locales: locales}, %{"locale" => locale} = attrs) do
    case Enum.filter(locales, fn l10n -> l10n.code == locale end) do
      [] ->
        {:error, :locale_not_found}
      [%Locale{params: params}] ->
        {:ok, Map.put(attrs, "l10n", params)}
    end
  end

  defp render_html(%Template{syntax: "mustache", body: body}, attrs) do
    case :bbmustache.render(body, map_to_keyword(attrs), key_type: :atom) do
      html when is_binary(html) ->
        {:ok, html}
    end
  end
  defp render_html(%Template{syntax: "markdown", body: body}, _attrs) do
    case Earmark.as_html(body) do
      {:ok, html_doc, []} ->
        {:ok, html_doc}
    end
  end
  defp render_html(%Template{syntax: "iex", body: body}, attrs) do
    case EEx.eval_string(body, assigns: map_to_keyword(attrs)) do
      html when is_binary(html) ->
        {:ok, html}
    end
  end

  defp render_output(html, %{"format" => "text/html"}, _cache?) do
    {:ok, {"text/html", html}}
  end
  defp render_output(html, %{"format" => "application/json"} = attrs, _cache?) do
    case Poison.encode(%{body: html, params: attrs}) do
      {:ok, json} ->
        {:ok, {"application/json", json}}
      {:error, reason} ->
        {:error, reason}
    end
  end
  defp render_output(html, %{"format" => "application/pdf"} = attrs, true) do
    Cache.fetch(:crypto.hash(:sha256, html), fn ->
      render_output(html, attrs, false)
    end)
  end
  defp render_output(html, %{"format" => "application/pdf"}, false) do
    case PdfGenerator.generate(html, page_size: "A4") do
      {:ok, html} ->
        {:ok, content} = File.read(html)
        {:ok, {"application/pdf", content}}
      {:error, reason} ->
        {:error, reason}
    end
  end
  defp render_output(_html, %{"format" => format}, _cache?) do
    {:error, {:unsupported_format, format}}
  end

  defp map_to_keyword(attrs) when is_list(attrs),
    do: attrs
  defp map_to_keyword(attrs) when is_map(attrs),
    do: for {key, val} <- attrs, into: [], do: {String.to_atom(key), map_to_keyword(val)}
  defp map_to_keyword(attrs),
    do: attrs
end

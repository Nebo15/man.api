defmodule Man.Templates.Renderer do
  @moduledoc false
  alias Man.Templates.Template
  alias Man.Templates.API

  @doc """
  Prints a template.

  ## Examples

      iex> render_template(template, attrs)
      {:ok, html}

      iex> render_template(template, attrs)
      {:error, validation_errors_list}

  """
  def render_template(%Template{body: body, validation_schema: validation_schema} = template, attrs) do
    case NExJsonSchema.Validator.validate(validation_schema, attrs) do
      {:error, _} = errors ->
          errors
      _ ->
          {:ok, EEx.eval_string(body, assigns: modify_attrs(attrs))}
    end
  end

  defp modify_attrs(attrs),
    do: for {key, val} <- attrs, into: %{}, do: {String.to_atom(key), val}
end

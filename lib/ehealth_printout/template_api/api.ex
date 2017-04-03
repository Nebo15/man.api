defmodule EhealthPrintout.TemplateAPI do
  @moduledoc """
  The boundary for the TemplateAPI system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias EhealthPrintout.Repo

  alias EhealthPrintout.TemplateAPI.Template

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%Template{}, ...]

  """
  def list_templates do
    Repo.all(Template)
  end

  @doc """
  Gets a single template.

  Raises `Ecto.NoResultsError` if the Template does not exist.

  ## Examples

      iex> get_template!(123)
      %Template{}

      iex> get_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template!(id), do: Repo.get!(Template, id)

  @doc """
  Creates a template.

  ## Examples

      iex> create_template(%{field: value})
      {:ok, %Template{}}

      iex> create_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template(attrs \\ %{}) do
    %Template{}
    |> template_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a template.

  ## Examples

      iex> update_template(template, %{field: new_value})
      {:ok, %Template{}}

      iex> update_template(template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template(%Template{} = template, attrs) do
    template
    |> template_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Template.

  ## Examples

      iex> delete_template(template)
      {:ok, %Template{}}

      iex> delete_template(template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template(%Template{} = template) do
    Repo.delete(template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template changes.

  ## Examples

      iex> change_template(template)
      %Ecto.Changeset{source: %Template{}}

  """
  def change_template(%Template{} = template) do
    template_changeset(template, %{})
  end

  defp template_changeset(%Template{} = template, attrs) do
    template
    |> cast(attrs, [:body, :json_schema])
    |> validate_required([:body, :json_schema])
  end

  defp modify_attrs(attrs), do: for {key, val} <- attrs, into: %{}, do: {String.to_atom(key), val}

  @doc """
  Prints a template.

  ## Examples

      iex> print_template(template, attrs)
      {:ok, html}

      iex> print_template(template, attrs)
      {:error, validation_errors_list}

  """
  def print_template(%Template{} = template, attrs) do
    body = Map.get(template, :body)
    json_schema = Map.get(template, :json_schema)

    case NExJsonSchema.Validator.validate(json_schema, attrs) do
      {:error, _} = errors -> errors
      _ -> {:ok, EEx.eval_string(body, assigns: modify_attrs(attrs))}
    end
  end
end

defmodule Man.Templates.API do
  @moduledoc """
  The boundary for the TemplateAPI system.
  """
  import Ecto.{Query, Changeset}, warn: false
  alias Man.Repo
  alias Man.Templates.Template

  @fields [:title, :description, :syntax, :body, :validation_schema, :labels]
  @required_fields [:title, :syntax, :body]
  @supported_formats ["mustache", "markdown"]

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%Template{}, ...]

  """
  def list_templates,
    do: Repo.all(Template)

  @doc """
  Gets a single template.

  ## Examples

      iex> get_template(123)
      {:ok, %Template{}}

      iex> get_template(456)
      {:error, :not_found}

  """
  def get_template(id) do
    case Repo.get(Template, id) do
      nil -> {:error, :not_found}
      template -> {:ok, template}
    end
  end

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
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:description, max: 510)
    # |> validate_labels(:labels, max_length: 100)
    |> validate_inclusion(:syntax, @supported_formats)
    |> cast_embed(:locales, with: &locale_changeset/2)
  end

  defp locale_changeset(%Template.Locale{} = template, attrs) do
    template
    |> cast(attrs, [:locale, :params])
    |> validate_required([:locale, :params])
  end

  defp validate_labels(changeset, field, opts) do
    validate_change changeset, field, {:cast, :string}, fn _, labels ->
      if Enum.all?(labels, &is_binary/1),
          do: validate_labels_length(labels, field, opts),
        else: [{field, {"is not a valid label", [cast: :string]}}]
    end
  end

  defp validate_labels_length(labels, field, opts) do
    max_length = Keyword.get(opts, :max_length, 100)
    if Enum.all?(labels, fn label -> String.length(label) > max_length end),
        do: [],
      else: [{field, {"should have labels with no more than #{inspect max_length} character(s)", [length: max_length]}}]
  end
end

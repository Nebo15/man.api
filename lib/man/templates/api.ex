defmodule Man.Templates.API do
  @moduledoc """
  The boundary for the TemplateAPI system.
  """
  import Ecto.{Query, Changeset}, warn: false
  alias Man.Repo
  alias Man.Templates.Template
  alias Ecto.Multi

  @fields [:title, :description, :syntax, :body, :validation_schema, :labels]
  @required_fields [:title, :syntax, :body]
  @supported_formats ["mustache", "markdown", "iex"]

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%Template{}, ...]

  """
  def list_templates(conditions \\ %{}) do
    Template
    |> maybe_filter_title(conditions)
    |> Repo.all()
  end

  defp maybe_filter_title(query, %{"title" => title}) do
    title_ilike = "%" <> title <> "%"

    query
    |> where([t], ilike(t.title, ^title_ilike))
  end
  defp maybe_filter_title(query, _),
    do: query

  @doc """
  Returns the list of labels.

  ## Examples

      iex> list_labels()
      ["label", ...]

  """
  def list_labels do
    Repo.all from t in Template,
      distinct: true,
      select: fragment("unnest(?)", t.labels)
  end

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
  Replace a template.

  ## Examples

      iex> replace_template(template, %{field: new_value})
      {:ok, %Template{}}

      iex> replace_template(template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def replace_template(id, attrs) do
    result =
      Multi.new
      |> Multi.delete_all(:delete, from(t in Template, where: t.id == ^id))
      |> Multi.insert(:insert, template_changeset(build_template_by_id(id), attrs))
      |> Repo.transaction()

    case result do
      {:ok, %{insert: template}} -> {:ok, template}
      {:error, :insert, changeset, _} -> {:error, changeset}
    end
  end

  defp build_template_by_id(nil),
    do: %Template{}
  defp build_template_by_id(id) when is_number(id),
    do: %Template{id: id}
  defp build_template_by_id(id) when is_binary(id) do
    {id, ""} = Integer.parse(id)
    build_template_by_id(id)
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

  # TODO: validations tests
  defp template_changeset(%Template{} = template, attrs) do
    template
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:description, max: 510)
    # TODO: Max labels count
    # |> validate_labels(:labels, max_length: 100)
    # TODO: Don't allow to set multiple locales with repeated keys
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

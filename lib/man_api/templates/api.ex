defmodule Man.Templates.API do
  @moduledoc """
  The boundary for the TemplateAPI system.
  """
  import Ecto.{Query, Changeset}, warn: false
  alias Man.Repo
  alias Man.Templates.Template
  alias Ecto.Multi
  alias Ecto.Paging

  @fields [:title, :description, :syntax, :body, :validation_schema, :labels]
  @required_fields [:title, :syntax, :body]
  @supported_formats ["mustache", "markdown", "iex"]
  @locale_code_pattern ~r/^[a-z]{2}([-_][A-Z]{2})?$/

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      {[%Template{}, ...], %Ecto.Paging{}}

  """
  def list_templates(conditions \\ %{}, %Paging{} = paging \\ %Paging{limit: 50}) do
    Template
    |> maybe_filter_title(conditions)
    |> maybe_filter_labels(conditions)
    |> Repo.page(paging)
  end

  defp maybe_filter_title(query, %{"title" => title}) when is_binary(title) do
    title_ilike = "%" <> title <> "%"
    where(query, [t], ilike(t.title, ^title_ilike))
  end

  defp maybe_filter_title(query, _), do: query

  defp maybe_filter_labels(query, %{"labels" => labels_stirng}) when is_binary(labels_stirng) do
    labels =
      labels_stirng
      |> String.split(",")
      |> Enum.map(&String.trim/1)

    where(query, [t], fragment("jsonb_build_array(?)->0 \\?& ?::character varying[255][]", t.labels, ^labels))
  end

  defp maybe_filter_labels(query, _), do: query

  @doc """
  Returns the list of labels.

  ## Examples

      iex> list_labels()
      ["label", ...]

  """
  def list_labels do
    Repo.all(
      from(
        t in Template,
        distinct: true,
        select: fragment("unnest(?)", t.labels)
      )
    )
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
      Multi.new()
      |> Multi.delete_all(:delete, from(t in Template, where: t.id == ^id))
      |> Multi.insert(:insert, template_changeset(build_template_by_id(id), attrs))
      |> Repo.transaction()

    case result do
      {:ok, %{insert: template}} -> {:ok, template}
      {:error, :insert, changeset, _} -> {:error, changeset}
    end
  end

  defp build_template_by_id(id) when is_number(id), do: %Template{id: id}

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

  defp template_changeset(%Template{} = template, attrs) do
    template
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:description, max: 510)
    |> validate_length(:body, min: 1)
    |> validate_length(:labels, max: 100)
    |> validate_inclusion(:syntax, @supported_formats)
    |> validate_uniqueness_by(:locales, fn %{"code" => code} -> code end)
    |> cast_embed(:locales, with: &locale_changeset/2)
  end

  defp locale_changeset(%Template.Locale{} = template, attrs) do
    template
    |> cast(attrs, [:code, :params])
    |> validate_required([:code, :params])
    |> validate_format(:code, @locale_code_pattern)
  end

  defp validate_uniqueness_by(%Ecto.Changeset{params: params} = changeset, field, fun) do
    case Map.fetch(params, Atom.to_string(field)) do
      :error ->
        changeset

      {:ok, values} when is_list(values) ->
        count = length(values)

        uniq_count =
          values
          |> Enum.uniq_by(fun)
          |> length()

        if uniq_count == count,
          do: changeset,
          else: add_error(changeset, field, "contains duplicate fields", validation: [:unique])

      {:ok, _values} ->
        changeset
    end
  end
end

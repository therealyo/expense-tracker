defmodule ExpenseTracker.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias ExpenseTracker.Repo

  alias ExpenseTracker.Categories.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    query = from c in Category, order_by: [desc: c.inserted_at]

    query
    |> Repo.all()
    |> Repo.preload(:expenses)
    |> Enum.map(fn c -> Category.with_total_spent(c) end)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id),
    do:
      Category
      |> Repo.get!(id)
      |> Repo.preload(:expenses)
      |> Category.with_total_spent()

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs) do
    with {:ok, category = %Category{}} <-
           %Category{}
           |> Category.changeset(attrs)
           |> Repo.insert() do
      {:ok, category}
    end
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    with {:ok, category = %Category{}} <-
           category
           |> Category.changeset(attrs)
           |> Repo.update() do
      {:ok, category}
    end
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  def categories_select_options do
    Repo.all(from c in Category, order_by: [asc: c.name], select: {c.name, c.id})
  end

  # def subscribe_to_changes() do
  #   Phoenix.PubSub.subscribe(ExpenseTracker.PubSub, "categories")
  # end
  #
  # def broadcast(message) do
  #   Phoenix.PubSub.broadcast(ExpenseTracker.PubSub, "categories", message)
  # end
end

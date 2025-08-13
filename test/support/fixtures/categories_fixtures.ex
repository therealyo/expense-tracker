defmodule ExpenseTracker.CategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExpenseTracker.Categories` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some description",
        monthly_budget: 42,
        name: "some name"
      })
      |> ExpenseTracker.Categories.create_category()

    category
  end
end

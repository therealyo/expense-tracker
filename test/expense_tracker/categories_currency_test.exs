defmodule ExpenseTracker.CategoriesCurrencyTest do
  use ExpenseTracker.DataCase
  alias ExpenseTracker.Categories
  alias ExpenseTracker.Categories.Category
  alias ExpenseTracker.Expenses
  alias ExpenseTracker.Expenses.Expense

  test "category defaults currency USD" do
    {:ok, cat} = Categories.create_category(%{name: "A", description: "B", monthly_budget: 1000})
    assert cat.currency == :USD
  end

  test "category accepts human input for budget" do
    {:ok, cat} =
      Categories.create_category(%{name: "A", description: "B", monthly_budget: "12.34"})

    assert cat.monthly_budget == 1234
  end

  test "expense accepts human input for amount and keeps/inherits currency" do
    {:ok, cat} =
      Categories.create_category(%{
        name: "A",
        description: "B",
        monthly_budget: 1000,
        currency: :USD
      })

    {:ok, exp} =
      Expenses.create_expense(%{
        description: "coffee",
        amount: "1.99",
        date: DateTime.utc_now(),
        category_id: cat.id
      })

    assert exp.amount == 199
    assert exp.currency == :USD
  end

  test "reject negative amounts and budgets" do
    cs =
      Category.changeset(%Category{}, %{
        name: "A",
        description: "B",
        monthly_budget: -1,
        currency: :USD
      })

    refute cs.valid?

    cs2 =
      Expense.changeset(%Expense{}, %{
        description: "x",
        amount: -1,
        date: DateTime.utc_now(),
        category_id: 1,
        currency: :USD
      })

    refute cs2.valid?
  end

  test "invalid currency rejected" do
    cs =
      Category.changeset(%Category{}, %{
        name: "A",
        description: "B",
        monthly_budget: 1,
        currency: :XYZ
      })

    refute cs.valid?
  end
end

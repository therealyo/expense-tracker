defmodule ExpenseTracker.Expenses do
  alias ExpenseTracker.Expenses
  alias ExpenseTracker.Expenses.Expense
  alias ExpenseTracker.Repo

  def list_expenses do
    Expense
    |> Repo.all()
    |> Repo.preload(:category)
  end

  def get_expense!(id) do
    Expense
    |> Repo.get!(id)
    |> Repo.preload(:category)
  end

  def create_expense(attrs) do
    with {:ok, expense = %Expense{}} <-
           %Expense{}
           |> Expense.changeset(attrs)
           |> Repo.insert() do
      {:ok, expense}
    end
  end

  def update_expense(%Expense{} = expense, attrs) do
    expense
    |> Expense.changeset(attrs)
    |> Repo.update()
  end

  def delete_expense(%Expense{} = expense), do: Repo.delete(expense)

  def change_expense(%Expense{} = expense, attrs \\ %{}) do
    Expense.changeset(expense, attrs)
  end
end

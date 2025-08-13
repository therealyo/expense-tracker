defmodule ExpenseTrackerWeb.PageController do
  use ExpenseTrackerWeb, :controller

  def home(conn, _params) do
    recent =
      ExpenseTracker.Expenses.list_expenses()
      |> Enum.take(5)

    render(conn, :home, recent_expenses: recent)
  end
end

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# This script inserts some sample Categories and Expenses.
# Amounts are in dollars in this file and converted to cents by changesets.
#
# Use bang functions so failures are visible during seeding.

alias ExpenseTracker.{Repo}
alias ExpenseTracker.Categories
alias ExpenseTracker.Categories.Category
alias ExpenseTracker.Expenses
alias ExpenseTracker.Expenses.Expense

now = DateTime.utc_now() |> DateTime.truncate(:second)

# Helper to create a category with optional expenses
create_category = fn name, monthly_budget_dollars, desc, expenses ->
  {:ok, category} =
    Categories.create_category(%{
      name: name,
      description: desc,
      currency: :USD,
      monthly_budget: to_string(monthly_budget_dollars)
    })

  Enum.each(expenses, fn %{description: d, amount: a, date: dt, notes: n} ->
    {:ok, _} =
      Expenses.create_expense(%{
        description: d,
        currency: :USD,
        amount: to_string(a),
        date: dt,
        notes: n,
        category_id: category.id
      })
  end)

  category
end

# Wipe existing data for idempotency in development
# Comment out for production if desired
Repo.delete_all(Expense)
Repo.delete_all(Category)

# Seed data
create_category.(
  "Groceries",
  600.00,
  "Monthly grocery budget",
  [
    %{description: "Supermarket run", amount: 82.45, date: now, notes: "weekly"},
    %{description: "Farmers market", amount: 24.10, date: now, notes: "produce"}
  ]
)

create_category.(
  "Transport",
  250.00,
  "Public transport and fuel",
  [
    %{description: "Metro card", amount: 40.00, date: now, notes: "refill"},
    %{description: "Gas", amount: 55.30, date: now, notes: "top-up"}
  ]
)

create_category.(
  "Dining Out",
  200.00,
  "Restaurants and cafes",
  [
    %{description: "Lunch", amount: 14.90, date: now, notes: "workday"},
    %{description: "Coffee", amount: 4.50, date: now, notes: "latte"}
  ]
)

create_category.(
  "Utilities",
  300.00,
  "Electricity, water, internet",
  [
    %{description: "Electricity bill", amount: 120.00, date: now, notes: "monthly"},
    %{description: "Internet bill", amount: 55.00, date: now, notes: "monthly"}
  ]
)

IO.puts("Seed data inserted successfully.")

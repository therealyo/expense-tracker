defmodule ExpenseTracker.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExpenseTracker.Expenses.Expense
  alias ExpenseTracker.Currencies

  schema "categories" do
    field :name, :string
    field :description, :string
    field :monthly_budget, :integer
    field :currency, Ecto.Enum, values: Currencies.available_currencies(), default: :USD
    field :total_spent, :integer, default: 0, virtual: true

    has_many :expenses, Expense,
      preload_order: [asc: :date],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    attrs = Currencies.normalize_money(attrs, :monthly_budget)

    category
    |> cast(attrs, [:name, :description, :currency, :monthly_budget])
    |> cast_assoc(
      :expenses,
      sort_param: :expenses_sort,
      drop_param: :expenses_drop
    )
    |> validate_inclusion(:currency, Currencies.available_currencies())
    |> validate_number(:monthly_budget, greater_than_or_equal_to: 0)
    |> validate_required([:name, :description, :currency, :monthly_budget])
  end

  def with_total_spent(%__MODULE__{} = category) do
    %{
      category
      | total_spent: Enum.sum_by(category.expenses, fn e -> e.amount end)
    }
  end
end

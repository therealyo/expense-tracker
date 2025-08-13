defmodule ExpenseTracker.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExpenseTracker.Categories.Expense

  schema "categories" do
    field :name, :string
    field :description, :string
    field :monthly_budget, :integer
    field :total_spent, :integer, default: 0, virtual: true

    has_many :expenses, Expense, on_replace: :delete
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :monthly_budget])
    |> cast_assoc(:expenses,
      sort_param: :expenses_sort,
      drop_param: :expenses_drop
    )
    |> validate_required([:name, :description, :monthly_budget])
  end

  def with_total_spent(%__MODULE__{} = category) do
    %{
      category
      | total_spent: Enum.sum_by(category.expenses, fn e -> e.amount end)
    }
  end
end

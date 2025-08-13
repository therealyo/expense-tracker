defmodule ExpenseTracker.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExpenseTracker.Categories.Expense

  schema "categories" do
    field :name, :string
    field :description, :string
    field :monthly_budget, :integer

    has_many :expenses, Expense
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
end

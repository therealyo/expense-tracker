defmodule ExpenseTracker.Categories.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExpenseTracker.Categories.Category

  schema "expenses" do
    field :description, :string
    field :amount, :integer
    field :date, :utc_datetime
    field :notes, :string

    belongs_to :category, Category
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:description, :amount, :date, :notes])
    |> validate_required([:description, :amount, :date])
  end
end

defmodule ExpenseTracker.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExpenseTracker.Categories.Category
  alias ExpenseTracker.Currencies

  schema "expenses" do
    field :description, :string
    field :currency, Ecto.Enum, values: Currencies.available_currencies(), default: :USD
    field :amount, :integer
    field :date, :utc_datetime
    field :notes, :string

    belongs_to :category, Category
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    attrs = normalize_money(attrs, :amount)

    expense
    |> cast(attrs, [:description, :currency, :amount, :date, :notes, :category_id])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> validate_inclusion(:currency, Currencies.available_currencies())
    |> validate_required([:description, :amount, :date, :currency])
    |> foreign_key_constraint(:category_id)
  end

  defp normalize_money(%{} = attrs, key) do
    case Map.fetch(attrs, key) do
      {:ok, v} when is_binary(v) ->
        case Currencies.parse_dollars_to_cents(v) do
          {:ok, cents} -> Map.put(attrs, key, cents)
          {:error, _} -> attrs
        end

      _ ->
        attrs
    end
  end
end

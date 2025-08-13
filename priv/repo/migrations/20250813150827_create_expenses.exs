defmodule ExpenseTracker.Repo.Migrations.CreateExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :description, :string
      add :amount, :integer
      add :date, :utc_datetime
      add :notes, :string
      add :currency, :currency, default: "USD"

      add :category_id,
          references("categories", column: :id, on_delete: :delete_all),
          null: false

      timestamps(type: :utc_datetime)
    end
  end
end

defmodule ExpenseTracker.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    execute "CREATE TYPE currency AS ENUM('USD')"

    create table(:categories) do
      add :name, :string
      add :description, :string
      add :monthly_budget, :integer
      add :currency, :currency, default: "USD", null: false

      timestamps(type: :utc_datetime)
    end
  end
end

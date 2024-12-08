defmodule StockerApi.Repo.Migrations.CreateStocks do
  use Ecto.Migration

  def change do
    create table(:stocks, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :ticker, :string, size: 10
      add :created_at, :date

      timestamps()
    end

    create unique_index(:stocks, [:ticker])
  end
end

defmodule StockerApi.Repo.Migrations.CreateStockPrices do
  use Ecto.Migration

  def change do
    create table(:stock_prices, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :close, :decimal, null: false
      add :date, :date, null: false

      add :stock_id,
          references(
            :stocks,
            type: :binary_id,
            on_delete: :delete_all
          ),
          null: false

      timestamps()
    end

    create unique_index(:stock_prices, [:stock_id, :date])
  end
end

defmodule StockerApi.StockPrices do
  alias StockerApi.Repo
  alias StockerApi.StockPrices.StockPrice

  def insert_batch(batch) do
    Repo.insert_all(
      StockPrice,
      batch,
      on_conflict: {:replace_all_except, [:id, :stock_id, :inserted_at]},
      conflict_target: [:stock_id, :date]
    )
  end
end

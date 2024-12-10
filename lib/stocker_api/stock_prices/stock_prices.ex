defmodule StockerApi.StockPrices do
  alias StockerApi.Repo
  alias StockerApi.StockPrices.StockPrice

  import Ecto.Query

  def insert_batch(batch) do
    Repo.insert_all(
      StockPrice,
      batch,
      on_conflict: {:replace_all_except, [:id, :stock_id, :inserted_at]},
      conflict_target: [:stock_id, :date]
    )
  end

  def fetch_stock_prices(stock_id, params) do
    query =
      from(sp in StockPrice,
        where: sp.stock_id == ^stock_id,
        where: sp.date >= ^params["date_from"],
        where: sp.date <= ^params["date_to"],
        order_by: sp.date
      )

    case Repo.all(query) do
      {:error, Ecto.QueryError = error} ->
        {:error, error}

      stock_prices ->
        {:ok, stock_prices}
    end
  end
end

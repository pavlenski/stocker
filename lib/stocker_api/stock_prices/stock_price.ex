defmodule StockerApi.StockPrices.StockPrice do
  use StockerApi.Schema

  alias StockerApi.Stocks.Stock

  @derive {Jason.Encoder, except: [:__meta__, :stock]}
  schema "stock_prices" do
    field :close, :decimal
    field :date, :date

    belongs_to :stock, Stock

    timestamps()
  end
end

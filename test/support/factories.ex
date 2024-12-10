defmodule StockerApi.Factory do
  use ExMachina.Ecto, repo: StockerApi.Repo

  def stock_factory do
    %StockerApi.Stocks.Stock{
      name: sequence(:name, &"Stock #{&1}"),
      ticker: sequence(:ticker, &"TCK#{&1}")
    }
  end

  def stock_price_factory do
    %StockerApi.StockPrices.StockPrice{
      stock: build(:stock),
      close: Decimal.new(50),
      date: ~D[2020-10-10]
    }
  end
end

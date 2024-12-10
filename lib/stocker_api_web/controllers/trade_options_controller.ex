defmodule StockerApiWeb.TradeOptionsController do
  use StockerApiWeb, :controller

  alias StockerApi.StockPrices
  alias StockerApi.Stocks

  def trade_options(conn, %{"ticker" => ticker} = params) do
    with {:ok, stock} <- Stocks.find_by_ticker(ticker),
         {:ok, stock_prices} <- StockPrices.fetch_stock_prices(stock.id, params) do
      single_trade = calculate_single_trade_profit(stock_prices)
      multi_trade = calculate_multi_trade_profit(stock_prices)

      conn
      |> put_status(:ok)
      |> json(%{
        stock: stock,
        # stock_prices: stock_prices,
        single_trade: single_trade,
        multi_trade: multi_trade,
        params: params
      })
    end
  end

  defp calculate_single_trade_profit(stock_prices) do
    first_stock_price = hd(stock_prices)

    # accumulator, will be passed through the reduce function,
    # equaling in the final result once populated
    acc =
      %{
        max_profit: 0,
        buy_date: first_stock_price.date,
        buy_date_close: first_stock_price.close,
        sell_date: nil,
        sell_date_close: 0
      }

    Enum.reduce(
      # we start from the second element for the algorithm, get the remaining tail of the list
      tl(stock_prices),
      acc,
      fn stock_price, acc ->
        # using these here to avoid further logic nesting inside the true -> statement
        {new_min_date, new_min_close} =
          case Decimal.gt?(acc.buy_date_close, stock_price.close) do
            true ->
              {stock_price.date, stock_price.close}

            false ->
              {acc.buy_date, acc.buy_date_close}
          end

        profit = Decimal.sub(stock_price.close, new_min_close)

        # only in case our newly calculated profit is higher, shall we update the accumulator
        if profit > acc.max_profit do
          %{
            max_profit: profit,
            buy_date: new_min_date,
            buy_date_close: new_min_close,
            sell_date: stock_price.date,
            sell_date_close: stock_price.close
          }
        else
          acc
        end
      end
    )
  end

  # reusing the impl of calculate_single_trade_profit
  defp calculate_multi_trade_profit(stock_prices) do
    profit = 0

    stock_prices
    |> Enum.with_index()
    |> Enum.reduce(profit, fn {_stock_price, index}, acc ->
      single_trade =
        Enum.slice(stock_prices, index..-1//1)
        |> calculate_single_trade_profit()

      Decimal.add(acc, single_trade.max_profit)
    end)
  end
end

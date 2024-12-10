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

  def fetch_stock_prices(stock_id, date_from, date_to) do
    query =
      from(sp in StockPrice,
        where: sp.stock_id == ^stock_id,
        where: sp.date >= ^date_from,
        where: sp.date <= ^date_to,
        order_by: sp.date
      )

    case Repo.all(query) do
      {:error, Ecto.QueryError = error} ->
        {:error, error}

      stock_prices ->
        {:ok, stock_prices}
    end
  end

  def calculate_trading_options(stock_prices, date_ranges) do
    former_stock_prices =
      Enum.filter(stock_prices, fn sp ->
        sp.date >= date_ranges.former_date_from and sp.date <= date_ranges.former_date_to
      end)

    current_stock_prices =
      Enum.filter(stock_prices, fn sp ->
        sp.date >= date_ranges.current_date_from and sp.date <= date_ranges.current_date_to
      end)

    latter_stock_prices =
      Enum.filter(stock_prices, fn sp ->
        sp.date >= date_ranges.latter_date_from and sp.date <= date_ranges.latter_date_to
      end)

    former_trading_options =
      case Enum.empty?(former_stock_prices) do
        true ->
          "No data for former range"

        false ->
          %{
            date_from: date_ranges.former_date_from,
            date_to: date_ranges.former_date_to,
            single_trade: calculate_single_trade_profit(former_stock_prices),
            multi_trade: calculate_multi_trade_profit(former_stock_prices)
          }
      end

    current_trading_options =
      case Enum.empty?(current_stock_prices) do
        true ->
          "No data for current range"

        false ->
          %{
            date_from: date_ranges.current_date_from,
            date_to: date_ranges.current_date_to,
            single_trade: calculate_single_trade_profit(current_stock_prices),
            multi_trade: calculate_multi_trade_profit(current_stock_prices)
          }
      end

    latter_trading_options =
      case Enum.empty?(latter_stock_prices) do
        true ->
          "No data for current range"

        false ->
          %{
            date_from: date_ranges.latter_date_from,
            date_to: date_ranges.latter_date_to,
            single_trade: calculate_single_trade_profit(latter_stock_prices),
            multi_trade: calculate_multi_trade_profit(latter_stock_prices)
          }
      end

    %{
      former: former_trading_options,
      current: current_trading_options,
      latter: latter_trading_options
    }
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
        # maybe set these to first stock price fields as well
        sell_date: first_stock_price.date,
        sell_date_close: first_stock_price.close
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

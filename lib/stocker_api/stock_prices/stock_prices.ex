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
    # stock price range filtering
    former_stock_prices =
      Enum.filter(stock_prices, fn sp ->
        from = date_ranges.former_date_from
        to = date_ranges.former_date_to

        (Date.after?(sp.date, from) or Date.compare(sp.date, from) == :eq) and
          (Date.before?(sp.date, to) or Date.compare(sp.date, to) == :eq)
      end)

    current_stock_prices =
      Enum.filter(stock_prices, fn sp ->
        from = date_ranges.current_date_from
        to = date_ranges.current_date_to

        (Date.after?(sp.date, from) or Date.compare(sp.date, from) == :eq) and
          (Date.before?(sp.date, to) or Date.compare(sp.date, to) == :eq)
      end)

    latter_stock_prices =
      Enum.filter(stock_prices, fn sp ->
        from = date_ranges.latter_date_from
        to = date_ranges.latter_date_to

        (Date.after?(sp.date, from) or Date.compare(sp.date, from) == :eq) and
          (Date.before?(sp.date, to) or Date.compare(sp.date, to) == :eq)
      end)

    # queuing up trade options (single & multi) to be calculated asynchronously
    async_task_list = [
      Task.async(fn ->
        async_trading_options_for_range(
          former_stock_prices,
          date_ranges.former_date_from,
          date_ranges.former_date_to,
          "former"
        )
      end),
      Task.async(fn ->
        async_trading_options_for_range(
          current_stock_prices,
          date_ranges.current_date_from,
          date_ranges.current_date_to,
          "current"
        )
      end),
      Task.async(fn ->
        async_trading_options_for_range(
          latter_stock_prices,
          date_ranges.latter_date_from,
          date_ranges.latter_date_to,
          "latter"
        )
      end)
    ]

    trading_option_tasks = Task.await_many(async_task_list)

    # reduce calculations into a single response map
    response_map =
      Enum.reduce(trading_option_tasks, %{}, fn {range_type, response}, acc ->
        Map.put_new(acc, range_type, response)
      end)

    %{
      former: response_map["former"],
      current: response_map["current"],
      latter: response_map["latter"]
    }
  end

  # returns a {range_type, response} tuple, response being either a message or a map with single & multi-trade calculations
  defp async_trading_options_for_range(ranged_stock_prices, date_from, date_to, range_type) do
    case Enum.empty?(ranged_stock_prices) do
      true ->
        {range_type, "No data for #{range_type} range"}

      false ->
        {
          range_type,
          %{
            date_from: date_from,
            date_to: date_to,
            single_trade: calculate_single_trade_profit(ranged_stock_prices),
            multi_trade: calculate_multi_trade_profit(ranged_stock_prices)
          }
        }
    end
  end

  defp calculate_single_trade_profit(stock_prices) do
    first_stock_price = hd(stock_prices)

    # accumulator, will be passed through the reduce function,
    # equaling in the final result once populated
    acc =
      %{
        max_profit: Decimal.new(0),
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

        if profit > acc.max_profit do
          %{
            max_profit: profit,
            buy_date: new_min_date,
            buy_date_close: new_min_close,
            sell_date: stock_price.date,
            sell_date_close: stock_price.close
          }
        else
          %{
            max_profit: acc.max_profit,
            buy_date: new_min_date,
            buy_date_close: new_min_close,
            sell_date: acc.sell_date,
            sell_date_close: acc.sell_date_close
          }
        end
      end
    )
  end

  defp temp(stock_prices) do
    first_stock_price = hd(stock_prices)

    profit = Decimal.new(0)

    Enum.reduce(
      tl(stock_prices),
      profit,
      fn stock_price, profit_acc ->
        potential_profit = Decimal.sub(stock_price.close, first_stock_price.close)

        case Decimal.gt?(potential_profit, profit_acc) do
          true ->
            potential_profit

          false ->
            profit_acc
        end
      end
    )
  end

  # reusing the impl of calculate_single_trade_profit
  defp calculate_multi_trade_profit(stock_prices) do
    profit = Decimal.new(0)

    stock_prices
    |> Enum.with_index()
    |> Enum.reduce(profit, fn {_stock_price, index}, acc ->
      profit =
        Enum.slice(stock_prices, index..-1//1)
        |> temp()

      Decimal.add(acc, profit)
    end)
  end
end

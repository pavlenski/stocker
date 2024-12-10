defmodule StockerApiWeb.TradeOptionsController do
  use StockerApiWeb, :controller

  alias StockerApi.StockPrices
  alias StockerApi.Stocks
  alias StockerApiWeb.ErrorFallbackController

  action_fallback ErrorFallbackController

  def trade_options(conn, %{"ticker" => ticker} = params) do
    with {:ok, %{former_date_from: from, latter_date_to: to} = date_ranges} <-
           extract_and_validate_date_ranges(params),
         {:ok, stock} <- Stocks.find_by_ticker(ticker),
         {:ok, stock_prices} <- StockPrices.fetch_stock_prices(stock.id, from, to) do
      response =
        StockPrices.calculate_trading_options(stock_prices, date_ranges)

      conn
      |> put_status(:ok)
      |> json(%{
        stock: stock,
        params: params,
        current_dates: response.current,
        former_dates: response.former,
        latter_dates: response.latter
      })
    end
  end

  defp extract_and_validate_date_ranges(%{"date_from" => date_from, "date_to" => date_to}) do
    with {:ok, date_from} <- Date.from_iso8601(date_from),
         {:ok, date_to} <- Date.from_iso8601(date_to) do
      date_diff_in_days = Date.diff(date_to, date_from)

      {:ok,
       %{
         current_date_from: date_from,
         current_date_to: date_to,
         former_date_from: Date.add(date_from, -(date_diff_in_days + 1)),
         former_date_to: Date.add(date_from, -1),
         latter_date_from: Date.add(date_to, 1),
         latter_date_to: Date.add(date_to, date_diff_in_days + 1)
       }}
    else
      {:error, :invalid_format} ->
        {:error, "Invalid date formats"}

      {:error, :invalid_date} ->
        {:error, "Invalid dates"}
    end
  end

  defp extract_and_validate_date_ranges(_invalid_params), do: {:error, "Invalid date params"}
end

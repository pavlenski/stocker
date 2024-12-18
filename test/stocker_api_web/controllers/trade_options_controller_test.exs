defmodule StockerApiWeb.TradeOptionsControllerTest do
  use StockerApiWeb.ConnCase

  # import StockerApi.Factory
  alias StockerApi.Stocks.Stock
  alias StockerApi.Repo

  setup params do
    {:ok, %{conn: params.conn}}
  end

  describe "dummy" do
    test "testing dummy!", %{conn: _conn} do
      stock =
        %Stock{}
        |> Stock.create_changeset(%{
          name: "Test2",
          ticker: "TTS2",
          created_at: "2013-05-18"
        })
        |> Repo.insert!()

      stocks = Repo.all(Stock)
      s = Repo.get(Stock, stock.id)
      assert length(stocks) == 1
      assert s.ticker == "TTS2"
    end
  end

  # describe "GET /stocks/:ticker/trade-options" do
  #   test "return stock trading options", %{conn: conn} do
  #     stock = insert(:stock)
  #     _price1 = insert(:stock_price, stock: stock, close: Decimal.new(1), date: ~D[2020-10-10])
  #     _price2 = insert(:stock_price, stock: stock, close: Decimal.new(7), date: ~D[2020-10-11])
  #     _price3 = insert(:stock_price, stock: stock, close: Decimal.new(3), date: ~D[2020-10-13])
  #     _price4 = insert(:stock_price, stock: stock, close: Decimal.new(2), date: ~D[2020-10-16])
  #     _price4 = insert(:stock_price, stock: stock, close: Decimal.new(5), date: ~D[2020-10-17])
  #     _price4 = insert(:stock_price, stock: stock, close: Decimal.new(4), date: ~D[2020-10-18])

  #     conn =
  #       get(
  #         conn,
  #         "/api/stocks/#{stock.ticker}/trade-options?date_from=2020-10-10&date_to=2020-10-18"
  #       )

  #     json_response = json_response(conn, 200)

  #     assert %{"current_dates" => current_dates} = json_response
  #     assert %{"former_dates" => former_dates} = json_response
  #     assert %{"latter_dates" => latter_dates} = json_response
  #     assert %{"single_trade" => single_trade, "multi_trade" => multi_trade} = current_dates

  #     assert former_dates == "No data for former range"
  #     assert latter_dates == "No data for latter range"
  #     assert single_trade["max_profit"] == "6"
  #     assert single_trade["buy_date"] == "2020-10-10"
  #     assert single_trade["sell_date"] == "2020-10-11"
  #     assert multi_trade == "11"
  #   end
  # end
end

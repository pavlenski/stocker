defmodule StockerApiWeb.TradeOptionsControllerTest do
  use StockerApiWeb.ConnCase

  import StockerApi.Factory
  alias StockerApi.Stocks.Stock
  alias StockerApi.Repo

  setup params do
    IO.inspect(params)

    IO.inspect(Repo.config())

    # %Stock{}
    # |> Stock.create_changeset(%{
    #   name: "Test1",
    #   ticker: "TTST",
    #   created_at: "2012-05-18"
    # })
    # |> Repo.insert!()

    # stocks = Repo.all(Stock)
    # IO.inspect(stocks)

    # config = Testcontainers.RedisContainer.new()
    # {:ok, container} = Testcontainers.start_container(config)
    # ExUnit.Callbacks.on_exit(fn -> Testcontainers.stop_container(container.container_id) end)
    # {:ok, %{redis: container}}

    # config =
    #   PostgresContainer.new()
    #   |> PostgresContainer.with_database("stocker_api_test")
    #   |> PostgresContainer.with_password("postgres")
    #   |> PostgresContainer.with_user("postgres")
    #   |> PostgresContainer.with_port(4443)

    # {:ok, container} = Testcontainers.start_container(config)

    # {:ok, %{postgres: container}}
  end

  describe "dummy" do
    test "testing dummy!", %{conn: conn} = params do
      IO.inspect("1 2 3 testing")

      # stock = insert(:stock)

      # IO.inspect(conn)
      # IO.puts("  - - - - - - - - - - - - - - - -  -- - -  - --")
      # IO.inspect(params)
      # price1 = insert(:stock_price, stock: stock, close: Decimal.new(1), date: ~D[2020-10-10])
      # IO.inspect(stock)
      # IO.inspect(price1)

      assert 1 == 1
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

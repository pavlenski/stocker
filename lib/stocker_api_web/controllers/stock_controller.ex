defmodule StockerApiWeb.StockController do
  use StockerApiWeb, :controller

  alias StockerApi.Stocks
  alias StockerApiWeb.ErrorFallbackController

  action_fallback ErrorFallbackController

  def create(conn, %{"stock" => stock} = _params) do
    with {:ok, stock} <- Stocks.create_stock(stock) do
      conn
      |> put_status(:created)
      |> json(%{created_stock: stock})
    end
  end

  def update(conn, %{"id" => stock_id, "stock" => stock_params} = _params) do
    with {:ok, stock} <- Stocks.find_by_id(stock_id),
         {:ok, updated_stock} <- Stocks.update_stock(stock, stock_params) do
      conn
      |> put_status(:ok)
      |> json(%{updated_stock: updated_stock})
    end
  end

  def delete(conn, %{"id" => stock_id} = _params) do
    with {:ok, stock} <- Stocks.find_by_id(stock_id),
         {:ok, _deleted_stock} <- Stocks.delete_stock(stock) do
      send_resp(conn, :no_content, "")
    end
  end
end

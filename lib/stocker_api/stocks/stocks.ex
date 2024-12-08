defmodule StockerApi.Stocks do
  alias StockerApi.Repo
  alias StockerApi.Stocks.Stock

  def find_by_id(stock_id) do
    case Repo.get(Stock, stock_id) do
      nil ->
        {:error, "no stock with id #{stock_id} found"}

      stock ->
        {:ok, stock}
    end
  end

  def create_stock(params) do
    stock =
      %Stock{}
      |> Stock.create_changeset(params)

    case Repo.insert(stock) do
      {:ok, stock} ->
        {:ok, stock}

      {:error, _changeset} = changeset_error ->
        changeset_error
    end
  end

  def update_stock(stock, params) do
    stock =
      stock
      |> Stock.update_changeset(params)

    case Repo.update(stock) do
      {:ok, stock} ->
        {:ok, stock}

      {:error, _changeset} = changeset_error ->
        changeset_error
    end
  end

  def delete_stock(%Stock{} = stock) do
    case Repo.delete(stock) do
      {:ok, deleted_stock} ->
        {:ok, deleted_stock}

      {:error, _changeset} = changeset_error ->
        changeset_error
    end
  end
end

defmodule StockerApi.Stocks.Stock do
  use StockerApi.Schema

  import Ecto.Changeset

  alias StockerApi.Stocks.Stock

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "stocks" do
    field :name, :string
    field :ticker, :string
    field :created_at, :date

    timestamps()
  end

  def create_changeset(%Stock{id: nil} = stock, attrs) do
    stock
    |> cast(attrs, [
      :name,
      :ticker,
      :created_at
    ])
    |> unique_constraint(:ticker)
  end

  def update_changeset(%Stock{} = stock, attrs) do
    stock
    |> cast(attrs, [
      :name,
      :ticker,
      :created_at
    ])
    |> unique_constraint(:ticker)
  end
end

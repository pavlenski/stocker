# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     StockerApi.Repo.insert!(%StockerApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias StockerApi.Repo

alias StockerApi.Stocks.Stock

_apple =
  %Stock{}
  |> Stock.create_changeset(%{
    name: "Apple",
    ticker: "AAPL",
    created_at: "1980-12-12"
  })
  |> Repo.insert!()

_google =
  %Stock{}
  |> Stock.create_changeset(%{
    name: "Google",
    ticker: "GOOG",
    created_at: "2004-08-19"
  })
  |> Repo.insert!()

_amazon =
  %Stock{}
  |> Stock.create_changeset(%{
    name: "Amazon",
    ticker: "AMZN",
    created_at: "1997-05-15"
  })
  |> Repo.insert!()

_facebook =
  %Stock{}
  |> Stock.create_changeset(%{
    name: "Facebook",
    ticker: "META",
    created_at: "2012-05-18"
  })
  |> Repo.insert!()

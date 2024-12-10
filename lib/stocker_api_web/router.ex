defmodule StockerApiWeb.Router do
  use StockerApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", StockerApiWeb do
    pipe_through :api

    get "/healthcheck", HealthCheckController, :healthcheck

    get "/stocks", StockController, :index
    post "/stocks", StockController, :create
    patch "/stocks/:id", StockController, :update
    delete "/stocks/:id", StockController, :delete

    get "/stocks/:ticker/trade-options", TradeOptionsController, :trade_options

    post "/stocks/:id/import/csv", StockPriceImportController, :import_csv
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:stocker_api, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

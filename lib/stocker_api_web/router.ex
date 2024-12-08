defmodule StockerApiWeb.Router do
  use StockerApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", StockerApiWeb do
    pipe_through :api

    get "/healthcheck", HealthCheckController, :healthcheck
    get "/dummy", DummyController, :dummy_response
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:stocker_api, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

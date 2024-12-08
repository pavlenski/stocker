defmodule StockerApi.Repo do
  use Ecto.Repo,
    otp_app: :stocker_api,
    adapter: Ecto.Adapters.Postgres
end

{:ok, _} = Application.ensure_all_started(:ex_machina)

Testcontainers.start_link()
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(StockerApi.Repo, :manual)

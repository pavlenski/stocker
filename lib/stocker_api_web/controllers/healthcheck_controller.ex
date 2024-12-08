defmodule StockerApiWeb.HealthCheckController do
  use StockerApiWeb, :controller

  # plug Phoenix.Ecto.CheckRepoStatus

  def healthcheck(conn, _params) do
    send_resp(conn, 204, "")
  end
end

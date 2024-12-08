defmodule StockerApiWeb.DummyController do
  use StockerApiWeb, :controller

  def dummy_response(conn, params) do
    json(conn, %{message: "nogges", params: params})
  end
end

defmodule StockerApiWeb.ErrorFallbackController do
  use StockerApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(422)
    |> json(%{errors: traverse_errors(changeset)})
  end

  def call(conn, {:error, msg}) when is_binary(msg) do
    conn
    |> put_status(422)
    |> json(%{error: msg})
  end

  defp traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", inspect(value))
      end)
    end)
  end
end

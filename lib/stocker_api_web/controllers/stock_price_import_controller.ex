defmodule StockerApiWeb.StockPriceImportController do
  use StockerApiWeb, :controller

  alias StockerApi.StockPrices

  @csv_batch_amount 500

  def import_csv(conn, %{"id" => stock_id, "file" => raw_file} = _params) do
    zip_file = Unzip.LocalFile.open(raw_file.path)
    {:ok, unzip} = Unzip.new(zip_file)
    [entry | _] = Unzip.list_entries(unzip)

    time_now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Unzip.file_stream!(unzip, entry.file_name)
    |> Stream.map(fn c -> IO.iodata_to_binary(c) end)
    # decodes a stream of comma-separated lines into a stream of tuples
    |> CSV.decode(headers: true)
    |> Stream.map(&transform_row(&1, stock_id, time_now))
    |> Stream.chunk_every(@csv_batch_amount)
    |> Stream.each(fn batch ->
      StockPrices.insert_batch(batch)
    end)
    |> Stream.run()

    Unzip.LocalFile.close(zip_file)

    conn
    |> put_status(:ok)
    |> json(%{message: "imported #{raw_file.filename} successfully"})
  end

  defp transform_row({:ok, row}, stock_id, time_now) do
    %{
      stock_id: stock_id,
      date: Date.from_iso8601!(row["Date"]),
      close: Decimal.new(row["Close"]),
      # open: Decimal.new(row["Open"]),
      # high: Decimal.new(row["High"]),
      # low: Decimal.new(row["Low"]),
      # adj_close: Decimal.new(row["Adj Close"]),
      # volume: String.to_integer(row["Volume"]),
      inserted_at: time_now,
      updated_at: time_now
    }
  end
end

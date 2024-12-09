defmodule StockerApiWeb.StockPriceImportController do
  use StockerApiWeb, :controller

  require Logger
  alias StockerApi.StockPrices

  @csv_batch_amount 500

  def import_csv(conn, %{"id" => stock_id, "file" => raw_file} = _params) do
    zip_file = Unzip.LocalFile.open(raw_file.path)
    # wrap in with to handle potential errors
    {:ok, unzip} = Unzip.new(zip_file)
    [entry | _] = Unzip.list_entries(unzip)

    time_now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    Unzip.file_stream!(unzip, entry.file_name)
    |> Stream.map(fn c -> IO.iodata_to_binary(c) end)
    # decodes a stream of comma-separated lines into a stream of tuples
    |> CSV.decode(headers: true, validate_row_length: true)
    |> Stream.with_index()
    |> Stream.map(&transform_and_validate_row(&1, stock_id, time_now, entry.file_name))
    |> Stream.filter(fn row -> row != nil end)
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

  defp transform_and_validate_row({{:error, message}, index}, _stock_id, _time_now, filename) do
    Logger.warning(format_invalid_row_message(message, filename, index))
    nil
  end

  # validates row values, returning a correctly formed map or nil in case of an invalid row
  defp transform_and_validate_row({{:ok, row}, index}, stock_id, time_now, filename) do
    case valid_row?(row, filename, index) do
      true ->
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

      {false, message} ->
        Logger.warning(message)
        nil
    end
  end

  defp valid_row?(nil, file_name, line),
    do: {false, format_invalid_row_message("Row was read as nil", file_name, line)}

  defp valid_row?(row, file_name, line) do
    with {%Decimal{}, _remainder_of_binary} <- Decimal.parse(row["Close"]),
         {:ok, %Date{}} <- Date.from_iso8601(row["Date"]) do
      true
    else
      :error ->
        {false,
         format_invalid_row_message("Couldn't parse value of row into Decimal", file_name, line)}

      {:error, :invalid_format} ->
        {false,
         format_invalid_row_message("Invalid date format of value in row", file_name, line)}

      {:error, :invalid_date} ->
        {false, format_invalid_row_message("Invalid date value in row", file_name, line)}
    end
  end

  defp format_invalid_row_message(message, file_name, line) when is_binary(message) do
    # adding two to the files since the csv's include headers + 1 for counting from 0
    "#{file_name}:#{line + 2}: #{message}"
  end
end

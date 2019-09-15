defmodule Mix.Tasks.Ftbl.Load do
  @moduledoc """
  Loads football data results from a CSV file

      mix ftbl.load path /tmp/data.csv
      mix ftbl.load url http://localhost/data.csv

  Use path to load a CSV file from the file system.
  """
  use Mix.Task

  @shortdoc "Import the data from a CSV file."
  def run(["path", path]) when is_binary(path) do
    if File.exists?(path) do
      load_file(path)
    else
      Mix.raise("File not exists in path: #{path}")
    end
  end

  @shortdoc "Download a CSV file from a URL and import the data"
  def run(["url", url]) when is_binary(url) do
    :inets.start()
    :ssl.start()

    tmp_path = :string.trim(:os.cmd('mktemp'))

    case :httpc.request(:get, {String.to_charlist(url), []}, [], stream: tmp_path) do
      {:ok, :saved_to_file} ->
        tmp_path |> List.to_string() |> load_file
        :ok = tmp_path |> :file.delete()

      {:error, _reason} ->
        Mix.raise("Error downloading from URL: #{url}")

      _ ->
        Mix.raise("Unexpected error while making a request")
    end
  end

  def run(_opts), do: help()

  defp help do
    Mix.shell().info(~S(Load data results from a CSV file

    mix ftbl.load path /tmp/data.csv
    mix ftbl.load url http://localhost/data.csv
    ))
  end

  defp load_file(path) when is_binary(path) do
    case File.stream!(path, [encoding: :utf8], :line) do
      %File.Stream{path: ^path} = stream -> process_stream(stream)
      _ -> Mix.raise("Could not read the file from this path: #{path}")
    end
  end

  import Ftbl.CSVRow, only: [from_csv_row: 1]

  @doc """
  process_stream/1 creates structs of CSVRow from a stream
  """
  def process_stream(%File.Stream{} = stream) do
    stream
    |> Enum.reduce({[], []}, &process_stream_reducer/2)
    |> elem(1)
  end

  def process_stream_reducer(a, {cols, rows}) do
    [id | cols_head] = columns = a |> String.trim() |> String.split(",")
    # The first row will have an empty ID
    if id == "" do
      {["id" | cols_head], rows}
    else
      # Parse the table body
      strct = cols |> Enum.zip(columns) |> Enum.into(%{}) |> from_csv_row
      # This can be streamed to a source instead of accumulated
      # But this list is dependent on the head row for mapping
      {cols, [strct | rows]}
    end
  end
end

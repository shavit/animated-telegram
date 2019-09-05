defmodule Mix.Tasks.Ftbl.Load do
  @moduledoc """
  Loads footbal data results from a CSV file

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

    tmp_path =
      :os.cmd('mktemp')
      |> :string.trim()

    case :httpc.request(:get, {String.to_charlist(url), []}, [], stream: tmp_path) do
      {:ok, :saved_to_file} ->
        tmp_path |> List.to_string() |> load_file
        :ok = tmp_path |> :file.delete()

      {:error, _reason} ->
        Mix.raise("Error downloading from URL: #{url}")

      res ->
        IO.inspect(res)
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

  import Ftbl.CSVRow, only: [key_for_index: 1]

  defp process_stream(%File.Stream{} = stream) do
    Enum.map(stream, fn x ->
      struct =
        x
        |> String.trim()
        |> String.split(",")
        |> Enum.reduce({-1, []}, fn a, {cur, l} ->
          cur = cur + 1
          {cur, [{cur, a} | l]}
        end)
        |> elem(1)
        |> Enum.map(fn {key, value} ->
          {key_for_index(key), value}
        end)
        |> Map.new()

      IO.inspect(Kernel.struct!(Ftbl.CSVRow, struct))
    end)
  end
end

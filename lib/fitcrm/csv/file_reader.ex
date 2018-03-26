defmodule Fitcrm.Csv.FileReader do

  @moduledoc """
  Reads UTF-8 characters from a file and returns a Stream of lists of
  strings.
  """

  def rows(path) do
    IO.puts "File reader from CSVLixir"
    exists? = File.exists?(path)
    case exists? do
      false ->
        IO.puts "Doesn't exist"
        {:error, "File Trapped"}
      true ->
        f = File.open!(path, [:utf8])
        output = Fitcrm.Csv.IOReader.rows(f, &File.close/1)
        {:ok, output}
    end
  end
end

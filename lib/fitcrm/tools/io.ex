defmodule Fitcrm.Tools.Io do
alias Fitcrm.Tools.Io
alias Fitcrm.Csv.Csvparse

def csvimport(params) do
  if upload = params["file"] do
    file = upload.path
    filename = upload.filename
  end
    csv = Csvparse.read(file)
    case csv do
      {:error, message} ->
        IO.puts "Hander incorrect csv"
      {:ok, stream} ->
        stream
        |> Task.async_stream(&parse_csv(&1), max_concurrency: System.schedulers_online*2)
        |> Enum.each(fn row ->
          case row do
            {:error, message} ->
              IO.puts "Incorrect row in CSV"
            {:ok, payload} ->
              #Send to Function
              if irow = payload.enum do
                process_csv(irow)
              end
          end
        end)
    end

end

defp parse_csv(stream) do
  # Streams as row after row, operate on each row =)
  output = stream
  |> Enum.to_list
  |> IO.inspect
  |> Stream.map(fn(a) -> %{row: Enum.fetch!(a,0)} end)
  output
end

defp process_csv(row) do
  #Process Row as a list
  name = List.pop_at(row, 0) |> getvalue("name")
  protein = List.pop_at(row, 1) |> getvalue("protein")
  fats = List.pop_at(row, 2) |> getvalue("fats")
  carbs = List.pop_at(row, 3) |> getvalue("carbs")
  IO.puts "Row output =>  name: #{name}, protein: #{protein}, fats: #{fats}, carbs: #{carbs}, "
end



defp getvalue(element, field) do
  field = elem(element, 0)
  case field do
    nil ->
      IO.puts "Push this to the error console wehen created"
      {:error, "Failed at: Empty #{field} field"}
      ""
    _->
      field
  end
end















end

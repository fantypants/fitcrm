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
        meals = stream
        |> Task.async_stream(&parse_csv(&1), max_concurrency: System.schedulers_online*2)
        |> Enum.map(fn row ->
          case row do
            {:error, message} ->
              IO.puts "Incorrect row in CSV"
            {:ok, payload} ->
              #Send to Function
              if irow = payload.enum do
                IO.puts "Processing in IROW"
                getFields(irow)
                #food = process_csv(irow)
                #FitcrmWeb.UserController.insertfoods(%{"food" => food})
              end
          end
        end)
        transitionMap(meals)
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
  calories = (String.to_float(protein)*4) + (String.to_float(fats)*10) + (String.to_float(carbs)*4)
  %{name: name, protein: protein, fat: fats, carbs: carbs, calories: calories}
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

defp getFields(row) do
fst = row |> List.pop_at(0)
recipe = fst |> elem(1) |> List.pop_at(5) |> elem(0)
type = fst |> elem(1) |> List.pop_at(6) |> elem(0)
foodname = fst |> elem(1) |> List.pop_at(0) |> elem(0)
fat = fst |> elem(1) |> List.pop_at(1) |> elem(0)
protein = fst |> elem(1) |> List.pop_at(2) |> elem(0)
carbs = fst |> elem(1) |> List.pop_at(3) |> elem(0)
qty = fst |> elem(1) |> List.pop_at(4) |> elem(0)
meal_name = fst |> elem(0)
%{"meal" => %{name: meal_name, type: type, recipe: recipe}, "foods" => %{name: foodname, fat: fat, protein: protein, carbs: carbs, qty: qty}}
end

defp transitionMap(meal) do
  meal |> Enum.group_by(fn(a) -> a["meal"] end) |> Enum.map(fn(a) -> IO.inspect a end)
end















end

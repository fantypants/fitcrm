defmodule Fitcrm.Tools.Io do
use FitcrmWeb, :controller
import Ecto.Query
alias Fitcrm.Foods.Food
alias Fitcrm.Tools.Io
alias Fitcrm.Csv.Csvparse
import FitcrmWeb.Authorize
alias Phauxth.Log
alias Fitcrm.Accounts
alias Fitcrm.Tools
alias Fitcrm.Accounts.User
alias Fitcrm.Tools.ClientTool
plug :user_check when action in [:index, :show]
plug :id_check when action in [:edit, :update, :delete]

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
                #getFields(irow)
                food = process_csv(irow)
                FitcrmWeb.UserController.insertfoods(%{"food" => food})
              end
          end
        end)
        #transitionMap(meals)
    end

end

def csvimport_meal(params) do
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
                meal = getFields(irow) |> IO.inspect
                #food = process_csv(irow)
                FitcrmWeb.MealController.insertMeal(%{"meal" => meal})
              end
          end
        end)
        #transitionMap(meals)
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
  quantity = List.pop_at(row, 5) |> getvalue("quantity")
  meal_ident = List.pop_at(row, 4) |> getvalue("meal_ident") |> split_meal_id |> IO.inspect
  IO.puts "Running Calories"
  calories = (String.to_float(protein)*4) + (String.to_float(fats)*10) + (String.to_float(carbs)*4)

  %{name: name, protein: protein, fat: fats, quantity: quantity, carbs: carbs, calories: calories, meal_ident: meal_ident}
end

defp split_meal_id(value) do
  value |> String.split(",") |> Enum.map(fn(a) -> String.to_integer(a) end)
end


defp getvalue(element, field) do
  field = elem(element, 0)
  case field do
    nil ->
      IO.puts "Push this to the error console wehen created"
      {:error, "Failed at: Empty #{field} field"}
      ""
    _->
    IO.puts "field is:"
      field |> IO.inspect
  end
end

defp getFields(row) do
meal_ident = List.pop_at(row, 0) |> elem(0)
name = List.pop_at(row, 1) |> elem(0)
type = List.pop_at(row, 2) |> elem(0)
recipe = List.pop_at(row, 3) |> elem(0)
foodid = getFood(meal_ident) |> IO.inspect
stats = getfoodStats(foodid) |> IO.inspect

original = %{name: name, type: type, recipe: recipe, foodid: foodid}
Map.merge(original, stats) |> IO.inspect
end

defp transitionMap(meal) do
  meals = meal |> Enum.map(fn(a) ->
    %{mealname: elem(Map.fetch(a, "meal"), 1).name, food: {elem(Map.fetch(a, "foods"), 1).name, elem(Map.fetch(a, "foods"), 1).qty}}
  end)
    |> IO.inspect
end

defp getFood(id) do
  transformed_id = String.to_integer(id)
  query = Food
  Fitcrm.Repo.all(query)
  |> Enum.map(fn(a) ->
    identifier = Enum.find(a.meal_ident, fn(b) -> b == transformed_id end)
    case identifier do
      nil ->
        :error
      _->
        a.id
    end
  end) |> Enum.reject(fn(a) -> a == :error end)
end

defp updateFoods(list, meal_id) do
  list |> Enum.map(fn(a) -> FitcrmWeb.UserController.updatefood(a, meal_id) end)
end

defp getfoodStats(id_map) do
c = id_map |> Enum.map(fn(a) -> retrieveFoodValueC(Fitcrm.Repo.get!(Food, a)) end) |> Enum.sum
p = id_map |> Enum.map(fn(a) -> retrieveFoodValueP(Fitcrm.Repo.get!(Food, a)) end) |> Enum.sum
f = id_map |> Enum.map(fn(a) -> retrieveFoodValueF(Fitcrm.Repo.get!(Food, a)) end) |> Enum.sum
tc = id_map |> Enum.map(fn(a) -> retrieveFoodValueTC(Fitcrm.Repo.get!(Food, a)) end) |> Enum.sum
%{carbs: c, protein: p, fat: f, calories: tc}
end
defp retrieveFoodValueC(struct) do
  struct.carbs
end
defp retrieveFoodValueP(struct) do
  struct.protein
end
defp retrieveFoodValueF(struct) do
  struct.fat
end
defp retrieveFoodValueTC(struct) do
  struct.calories
end




#cottoncause.com












end

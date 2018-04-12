defmodule Fitcrm.Tools.ClientTool do
    import Ecto.Query
    alias Fitcrm.Tools.ClientTool
    alias FitcrmWeb.UserController
    alias Fitcrm.Accounts
    alias Fitcrm.Tools
    alias Fitcrm.Accounts.User
    alias Fitcrm.Tools.PhysicsTool
    alias Fitcrm.Plan.Workout
    alias Fitcrm.Foods.Meal

    def onboardclient(%{"user" => user, "params" => params}) do
      IO.puts "omboarded"
      weight = params["weight"] |> IO.inspect
      height = params["height"] |> IO.inspect
      activity = params["activity"] |> IO.inspect
      age = params["age"] |> IO.inspect
      sex = params["sex"] |> IO.inspect
      cystic = params["cystic"] |> IO.inspect
      ir = params["ir"] |> IO.inspect
      params_new = PhysicsTool.modifyQuestionResults(%{"sex" => sex, "height" => height, "weight" => weight, "activity" => activity, "age" => age, "cystic" => cystic}) |> IO.inspect
      bmr = PhysicsTool.calculate_tdee(params_new) |> IO.inspect
      tdee_original = PhysicsTool.scaleActivity(bmr, params_new["activity"]) |> IO.inspect
      case cystic do
        "Yes" ->
          cyst1 = 600
        "No" ->
          cyst1 = 0
      end

      case ir do
        "Yes" ->
          ir1 = 200
        "No" ->
          ir1 = 0
      end
      tdee = tdee_original - cyst1 - ir1
      changesetmap = PhysicsTool.compileResults(user, params_new, bmr, tdee) |> IO.inspect
      changesetmap
    end

    def getWorkoutID(level, type) do
      IO.puts "Selecting appliciable workout"
      IO.puts "Variables: #{type} & #{level}"
      query = from w in Workout, where: w.type == ^type
      workouts = Fitcrm.Repo.all(query) |> Enum.find(fn(a) -> a.level == level end) |> Map.fetch!(:id) |> IO.inspect
    end

    def getMealID(tdee) do
      IO.puts "Selecting appliciable meals"
      IO.puts "Variables: #{tdee}"
      bcals = tdee*0.25
      lcals = 0.75*0.4*tdee
      dcals = 0.75*0.6*tdee
      IO.puts "Calorie Variables => Breakfast: #{bcals}, Lunch: #{lcals}, Dinner: #{dcals}"
      bquery = from m in Meal, where: m.calories <= ^bcals, select: m.id
      lquery = from m in Meal, where: m.calories <= ^lcals, select: m.id
      dquery = from m in Meal, where: m.calories <= ^dcals, select: m.id
      breakfast = Fitcrm.Repo.all(bquery)
      lunch = Fitcrm.Repo.all(lquery) 
      dinner = Fitcrm.Repo.all(dquery) 
      %{breakfast: breakfast, lunch: lunch, dinner: dinner}

    end
















































end

defmodule Fitcrm.Tools.ClientTool do
    use Timex
    import Ecto.Query
    alias Fitcrm.Tools.ClientTool
    alias FitcrmWeb.UserController
    alias Fitcrm.Accounts
    alias Fitcrm.Tools
    alias Fitcrm.Accounts.User
    alias Fitcrm.Tools.PhysicsTool
    alias Fitcrm.Plan.Workout
    alias Fitcrm.Foods.Meal
    alias Fitcrm.Plan.Excercise
    alias Fitcrm.Plan.Weekday
    alias FitcrmWeb.WeekdayController

    def onboardclient(%{"user" => user, "params" => params}) do
      IO.puts "omboarded"
      weight = params["weight"] 
      height = params["height"] 
      activity = params["activity"] 
      age = params["age"] 
      sex = params["sex"] 
      cystic = params["cystic"] 
      ir = params["ir"] 
      params_new = PhysicsTool.modifyQuestionResults(%{"sex" => sex, "height" => height, "weight" => weight, "activity" => activity, "age" => age, "cystic" => cystic}) |> IO.inspect
      bmr = PhysicsTool.calculate_tdee(params_new) |> IO.inspect
      tdee_original = PhysicsTool.scaleActivity(bmr, params_new["activity"])
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
      changesetmap = PhysicsTool.compileResults(user, params_new, bmr, tdee)
      changesetmap
    end

    def getWorkoutID(level, type) do
      IO.puts "Selecting appliciable workout"
      IO.puts "Variables: #{type} & #{level}"
      query = from w in Workout, where: w.type == ^type
      workouts = Fitcrm.Repo.all(query) |> Enum.find(fn(a) -> a.level == level end) |> Map.fetch!(:id)
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

    def selectMeals(b_id, l_id, d_id) do
      b = b_id |> List.first
      l = l_id |> List.first
      d = d_id |> List.first
      %{"breakfast" => b, "lunch" => l, "dinner" => d}
    end

    def selectWorkout(id, day) do
      day_int = daySelector(day)
      query = from e in Excercise, where: e.workout_id == ^id
      ids = Fitcrm.Repo.all(query) |> Enum.filter(fn(a) -> a.day == day_int end) |> Enum.map(fn(a) -> a.id end)
      %{"excercises" => ids}
    end

    defp daySelector(day) do
      case day do
        "Monday" ->
          "1"
        "Tuesday" ->
          "2"
        "Wednesday" ->
          "3"
        "Thursday" ->
          "4"
        "Friday" ->
          "5"
        "Saturday" ->
          "6"
        "Sunday" ->
          "7"
      end
    end

    def getCurrentDay() do
      localDTG = Timex.today
      weekdayNumber = Timex.weekday(localDTG)
      Timex.day_name(weekdayNumber)
    end

    def getDate() do
      localDTG = Timex.today
      weekdayNumber = Timex.weekday(localDTG)
      day = Timex.day_name(weekdayNumber)
      weekdays = setupWeek(day)
    end

    defp setupWeek(day) do
      day_int = daySelector(day)
      localDTG = Timex.today
      [
        Date.add(Timex.local, 0),
        Date.add(Timex.local, 1),
        Date.add(Timex.local, 2),
        Date.add(Timex.local, 3),
        Date.add(Timex.local, 4),
        Date.add(Timex.local, 5),
        Date.add(Timex.local, 6)
      ] |> Enum.map(fn(a) -> {daySelector(Timex.day_name(Timex.weekday(a))), Timex.day_name(Timex.weekday(a))} end)
    end

    def queryTargetDates(conn) do
      day = "Monday"
      currentDate = Timex.local |> IO.inspect
      query = from w in Weekday, where: w.day == ^day, select: w.id
      Fitcrm.Repo.all(query) |> Enum.each(fn(a) -> WeekdayController.get_and_update(conn, a) end)
    end




















































end

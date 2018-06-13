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
    alias Fitcrm.Plan.Week
    alias FitcrmWeb.WeekdayController

    def onboardclient(%{"user" => user, "params" => params}) do
      IO.puts "omboarded"
      weight = params["weight"]
      height = params["height"]
      plantype = params["plantype"]
      planlevel = params["planlevel"]
      activity = params["activity"]
      age = params["age"]
      sex = params["sex"]
      cystic = params["cystic"] |> IO.inspect
      ir = params["ir"] |> IO.inspect
      veg = params["veg"] |> IO.inspect
      params_new = PhysicsTool.modifyQuestionResults(%{"ir" => ir, "veg" => veg, "pcos" => cystic, "plantype" => plantype, "planlevel" => planlevel, "sex" => sex, "height" => height, "weight" => weight, "activity" => activity, "age" => age, "cystic" => cystic}) |> IO.inspect
      bmr = PhysicsTool.calculate_tdee(params_new)
      IO.inspect params_new
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
      changesetmap |> IO.inspect
    end

    def getWorkoutID(level, type) do
      IO.puts "Selecting appliciable workout"
      IO.puts "Variables: #{type} & #{level}"
      query = from w in Workout, where: w.type == ^type
      workouts = Fitcrm.Repo.all(query) |> Enum.find(fn(a) -> a.level == level end) |> Map.fetch!(:id)
    end

    def getMealID(tdee, veg_param, pcos_param) do
      IO.puts "Selecting appliciable meals"
      IO.puts "Variables: #{tdee}"
      veg = veg_param
      pcos = pcos_param
      bcals = tdee*0.25
      lcals = 0.75*0.4*tdee
      dcals = 0.75*0.6*tdee
      IO.puts "Calorie Variables => Breakfast: #{bcals}, Lunch: #{lcals}, Dinner: #{dcals}"
      bquery = from m in Meal, where: m.calories <= ^bcals
      lquery = from m in Meal, where: m.calories <= ^lcals
      dquery = from m in Meal, where: m.calories <= ^dcals
      case veg do
        false ->
          case pcos do
            "No" ->
              #Not veg or PCOS
              breakfast = Fitcrm.Repo.all(bquery) |> Enum.filter(fn(a)-> a.veg == false && a.pcos == false end) |> Enum.map(fn(a) -> a.id end)
              lunch = Fitcrm.Repo.all(lquery) |> Enum.filter(fn(a)-> a.veg == false && a.pcos == false end) |> Enum.map(fn(a) -> a.id end)
              dinner = Fitcrm.Repo.all(dquery) |> Enum.filter(fn(a)-> a.veg == false && a.pcos == false end) |> Enum.map(fn(a) -> a.id end)
              "Yes" ->
                #Not veg, is pcos
              breakfast = Fitcrm.Repo.all(bquery) |> Enum.filter(fn(a)-> a.veg == false && a.pcos == true end) |> Enum.map(fn(a) -> a.id end)
              lunch = Fitcrm.Repo.all(lquery) |> Enum.filter(fn(a)-> a.veg == false && a.pcos == true end) |> Enum.map(fn(a) -> a.id end)
              dinner = Fitcrm.Repo.all(dquery) |> Enum.filter(fn(a)-> a.veg == false && a.pcos == true end) |> Enum.map(fn(a) -> a.id end)
          end
        true ->
          case pcos do
            "No" ->
              IO.puts "User is Vegetarian, Not PCOS"
              #is Veg, not pcos
              breakfast = Fitcrm.Repo.all(bquery) |> Enum.filter(fn(a)-> a.veg == true && a.pcos == false end) |> IO.inspect |> Enum.map(fn(a) -> a.id end)
              lunch = Fitcrm.Repo.all(lquery) |> Enum.filter(fn(a)-> a.veg == true && a.pcos == false end) |> Enum.map(fn(a) -> a.id end)
              dinner = Fitcrm.Repo.all(dquery) |> Enum.filter(fn(a)-> a.veg == true && a.pcos == false end) |> Enum.map(fn(a) -> a.id end)
              "Yes" ->
                #is veg, is pcos
              breakfast = Fitcrm.Repo.all(bquery) |> Enum.filter(fn(a)-> a.veg == true && a.pcos == true end) |> Enum.map(fn(a) -> a.id end)
              lunch = Fitcrm.Repo.all(lquery) |> Enum.filter(fn(a)-> a.veg == true && a.pcos == true end) |> Enum.map(fn(a) -> a.id end)
              dinner = Fitcrm.Repo.all(dquery) |> Enum.filter(fn(a)-> a.veg == true && a.pcos == true end) |> Enum.map(fn(a) -> a.id end)
          end
      end

      #breakfast = Fitcrm.Repo.all(bquery) |> Enum.filter(fn(a)-> a.type == "Breakfast" end) |> Enum.map(fn(a) -> a.id end)
      #lunch = Fitcrm.Repo.all(lquery) |> Enum.filter(fn(a)-> a.type == "Lunch" end) |> Enum.map(fn(a) -> a.id end)
      #dinner = Fitcrm.Repo.all(dquery) |> Enum.filter(fn(a)-> a.type == "Dinner" end) |> Enum.map(fn(a) -> a.id end)
      %{breakfast: breakfast, lunch: lunch, dinner: dinner}
    end

    def selectMeals(b_id, l_id, d_id) do
      b = b_id |> Enum.random
      l = l_id |> Enum.random
      d = d_id |> Enum.random
      %{"breakfast" => b, "lunch" => l, "dinner" => d}
    end

    def selectWorkout(id, day) do
      day_int = daySelector(day)
      IO.puts "DAY FROM WORKOUT SELECTOR IS"
      IO.inspect day
      query = from e in Excercise, where: e.workout_id == ^id
      ids = Fitcrm.Repo.all(query) |> Enum.filter(fn(a) -> a.day == day_int end) |> Enum.map(fn(a) -> "#{a.id}" end)
      %{"excercises" => ids} |> IO.inspect
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
      localDTG = Timex.local
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

    def getUserDates(user_id) do
        finish_date = Timex.local |> Date.add(1) |>  Timex.to_naive_datetime |> IO.inspect
        query = from w in Week, where: w.user_id == ^user_id
        finishes = Fitcrm.Repo.all(query) |> Enum.map(fn(a) -> %{id: a.id, finish: stripDate(a.end, "#{finish_date}")} end)
        updateSelector(finishes)
    end

    def getPlanDates() do
      #Propper Planner Date
      finish_date = Timex.local |> Date.add(1) |>  Timex.to_naive_datetime |> IO.inspect
      #Quick Planner Date
      #finish_date = Timex.local |>  Timex.to_naive_datetime |> IO.inspect
      query = Week
      finishes = Fitcrm.Repo.all(query) |> Enum.map(fn(a) -> %{id: a.id, finish: stripDate(a.end, "#{finish_date}")} end)
      updateSelector(finishes)
    end

    defp updateSelector(map) do
      map |> Enum.each(fn(a) ->
        if a.finish == true do
          WeekdayController.update_week(a.id)
        end
         end)
    end


    defp stripDate(date, finish) do
      IO.puts "Variables that will compare: #{date}, #{finish}"
      td = String.split(finish) |> List.first
      trimmed = String.starts_with?("#{date}", td)
    end




















































end

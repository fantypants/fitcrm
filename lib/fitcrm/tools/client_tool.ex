defmodule Fitcrm.Tools.ClientTool do
    alias Fitcrm.Tools.ClientTool
    alias FitcrmWeb.UserController
    alias Fitcrm.Accounts
    alias Fitcrm.Tools
    alias Fitcrm.Accounts.User
    alias Fitcrm.Tools.PhysicsTool

    def onboardclient(%{"user" => user, "params" => params}) do
      IO.puts "omboarded"
      weight = params["weight"] |> IO.inspect
      height = params["height"] |> IO.inspect
      activity = params["activity"] |> IO.inspect
      age = params["age"] |> IO.inspect
      sex = params["sex"] |> IO.inspect
      cystic = params["cystic"] |> IO.inspect
      params_new = PhysicsTool.modifyQuestionResults(%{"sex" => sex, "height" => height, "weight" => weight, "activity" => activity, "age" => age, "cystic" => cystic}) |> IO.inspect
      bmr = PhysicsTool.calculate_tdee(params_new) |> IO.inspect
      tdee = PhysicsTool.scaleActivity(bmr, params_new["activity"]) |> IO.inspect
      case cystic do
        "Yes" ->
          tdee = tdee - 600
        "No" ->
          tdee = tdee
      end
      changesetmap = PhysicsTool.compileResults(user, params_new, bmr, tdee) |> IO.inspect
      changesetmap
    end
















































end

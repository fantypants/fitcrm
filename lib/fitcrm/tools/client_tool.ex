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
















































end

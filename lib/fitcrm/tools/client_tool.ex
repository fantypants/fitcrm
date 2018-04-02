defmodule Fitcrm.Tools.ClientTool do
    alias Fitcrm.Tools.ClientTool
    alias FitcrmWeb.UserController
    alias Fitcrm.Accounts
    alias Fitcrm.Tools
    alias Fitcrm.Accounts.User
    alias Fitcrm.Tools.PhysicsTool

    def onboardclient(%{"user" => user, "params" => params}) do
      weight = params["weight"]
      height = params["height"]
      activity = params["activity"]
      age = params["age"]
      sex = params["sex"]
      cystic = params["cystic"]
      params_new = PhysicsTool.modifyQuestionResults(%{"sex" => sex, "height" => height, "weight" => weight, "activity" => activity, "age" => age, "cystic" => cystic}) |> IO.inspect
      bmr = PhysicsTool.calculate_tdee(params_new) |> IO.inspect
      tdee = PhysicsTool.scaleActivity(bmr, params_new["activity"]) |> IO.inspect
      changesetmap = PhysicsTool.compileResults(user, params_new, bmr, tdee) |> IO.inspect
      changesetmap
    end
















































end

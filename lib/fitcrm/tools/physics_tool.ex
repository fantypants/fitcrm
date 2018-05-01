defmodule Fitcrm.Tools.PhysicsTool do
    alias Fitcrm.Tools.PhysicsTool
    alias Fitcrm.Tools.ClientTool

      def calculate_tdee(%{"sex" => sex, "height" => height, "weight" => weight, "activity" => activity, "age" => age}) do
        case sex do
          "Male" ->
            bmr = 66 + (13.7 * weight) +(5 * height) - (6.8 * age)
          "Female" ->
            bmr = 655 + (9.6 * weight) +(1.8 * height) - (4.7 * age)
        end
        bmr
      end

      def scaleActivity(bmr, activity) do
        case activity do
          0 ->
            result = bmr * 1.2
          1 ->
            result = bmr * 1.375
          2 ->
            result = bmr * 1.55
          3 ->
             result = bmr * 1.725
          4 ->
            result = bmr * 1.9
        end
        result
      end

      def compileResults(user, map, bmr, tdee) do
        IO.inspect user
        new = %{"bmr" => bmr, "tdee" => tdee}
        Map.merge(map, new)
      end

      def modifyQuestionResults(%{"plantype" => plantype, "planlevel" => planlevel,"sex" => s, "height" => h, "weight" => w, "activity" => act, "age" => a, "cystic" => c}) do
        case act do
          "Sedentary" ->
            nact = 0
          "Light" ->
            nact = 1
          "Moderate" ->
            nact = 2
          "Heavy" ->
            nact = 3
          "Atheletic" ->
            nact = 4
        end
        weight = w |> convert |> elem(0)
        height = h |> convert |> elem(0)
        age = a |> String.to_integer
        nact
        %{"plantype" => plantype, "planlevel" => planlevel,"sex" => s, "height" => height, "weight" => weight, "activity" => nact, "age" => age}
      end

      def convert(val) do
        case val do
          "" ->
            ""
          _->
          Float.parse(val)
        end
      end



end

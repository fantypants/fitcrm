defmodule FitcrmWeb.PageController do
  use FitcrmWeb, :controller
  alias Fitcrm.Foods.Food

  def index(conn, _params) do
    changeset_params = %{name: "eggs", fat: "15.0", protein: "4.0", carbs: "2.0", calories: "432"}
    changeset = Food.changeset(%Food{}, changeset_params)
    Fitcrm.Repo.insert!(changeset)
    render conn, "index.html"
  end
end

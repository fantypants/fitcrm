defmodule FitcrmWeb.PageController do
  use FitcrmWeb, :controller
  alias Fitcrm.Foods.Food
  alias Fitcrm.Account
  alias Fitcrm.Foods.Food
  alias FitcrmWeb.UserController
  import Plug.Conn
  import Ecto.Query
  import FitcrmWeb.Authorize
  alias Phauxth.Log
  alias Fitcrm.Accounts
  alias Fitcrm.Tools
  alias Fitcrm.Accounts.User
  alias Fitcrm.Tools.ClientTool
  alias Fitcrm.Plan.Week
  alias FitcrmWeb.WeekdayController

  def index(conn, _params) do
    #changeset_params = %{name: "eggs", fat: "15.0", protein: "4.0", carbs: "2.0", calories: "432"}
    #changeset = Food.changeset(%Food{}, changeset_params)
    #Fitcrm.Repo.insert!(changeset)
    changeset = Accounts.change_user(%Accounts.User{})
    render conn, "index.html", changeset: changeset
  end
end

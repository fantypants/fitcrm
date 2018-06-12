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
  alias Fitcrm.Foods.Meal

  def index(conn, _params) do
    #changeset_params = %{name: "eggs", fat: "15.0", protein: "4.0", carbs: "2.0", calories: "432"}
    #changeset = Food.changeset(%Food{}, changeset_params)
    #Fitcrm.Repo.insert!(changeset)
    changeset = Accounts.change_user(%Accounts.User{})
    render conn, "index.html", changeset: changeset
  end

  def admindash(conn, %{"user_id" => id}) do
    admins = Fitcrm.Repo.all(from u in User, where: u.type == ^"Admin") |> Enum.count
    users = Fitcrm.Repo.all(from u in User, where: u.type == ^"Client") |> Enum.count
    meals = Fitcrm.Repo.all(Meal) |> Enum.count
    plans = Fitcrm.Repo.all(Week) |> Enum.count
    Tools.UserTool.update_referrals() |> IO.inspect



    system = %{meals: meals, plans: plans}
    user_stats = %{totalusers: users, totaladmin: admins}


    changeset = Accounts.change_user(%Accounts.User{})
    render conn, "admin_dash.html", changeset: changeset, user_stats: user_stats, system: system
  end

  def settings(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user_id" => id}) do
    changeset = Accounts.change_user(%Accounts.User{})
    authorized? = Fitcrm.Repo.get!(User, id).type
    case authorized? do
      "Client" ->
        render conn, "noaccess.html", changeset: changeset, user: user
      "Admin" ->
        render conn, "settings.html", changeset: changeset, user: user
    end
  end








end

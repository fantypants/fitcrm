defmodule FitcrmWeb.MealController do
  use FitcrmWeb, :controller
  import Plug.Conn
  import Phoenix.Controller
  import FitcrmWeb.Router.Helpers
  import FitcrmWeb.Authorize
  alias Fitcrm.Foods.Meal
  alias Fitcrm.Foods.Food
  alias Phauxth.Log
  alias Fitcrm.Accounts
  alias Fitcrm.Tools
  alias Fitcrm.Accounts.User
  alias Fitcrm.Tools.ClientTool

  # the following plugs are defined in the controllers/authorize.ex file
  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:edit, :update, :delete]


  def index(conn, _params) do
    meals = Fitcrm.Repo.all(Meal)
    render(conn, "index.html", meals: meals)
  end


  def csvupload(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    if param = params["food"] do
      id = params["id"]
      csv = params["food"]
      if upload = csv["file"] do
         Tools.Io.csvimport(csv)
      end
    else
      id = params["id"]
    end
    user = (id == to_string(user.id) and user) || Accounts.get(id)
    users = Accounts.list_users()
    changeset = Food.changeset(%Food{}, %{name: "test"})
    foods = Fitcrm.Repo.all(Food)
    conn
    |> render("foodindex.html", users: users, user: user, changeset: changeset, foods: foods)
  end

  def insertfoods(%{"food" => food}) do
    changeset_params = food |> IO.inspect
    changeset = Food.changeset(%Food{}, changeset_params)
    Fitcrm.Repo.insert!(changeset)
  end





  def new(conn, _params) do
    changeset = Meal.changeset(%Meal{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"meal" => meal_params}) do
    #changeset = Meal.changeset(%Meal{}, meal_params)

      if upload = meal_params["file"] do
         # PROCESS CSV
         file = meal_params["file"]
         Tools.Io.csvimport(file)

         #changeset = Tools.Io.csvimport(csv)
         #case Fitcrm.Repo.insert(changeset) do
        #   {:ok, meal} ->
        #     conn
        #     |> put_flash(:info, "Meal created successfully.")
        #     |> redirect(to: meal_path(conn, :show, meal))
        #   {:error, changeset} ->
        #     render(conn, "new.html", changeset: changeset)
        # end
      end
    meals = Fitcrm.Repo.all(Meal)
    render(conn, "index.html", meals: meals)
  end

  def show(conn, %{"id" => id}) do
    meal = Fitcrm.Repo.get!(Meal, id)
    render(conn, "show.html", meal: meal)
  end

  def edit(conn, %{"id" => id}) do
    meal = Fitcrm.Repo.get!(Meal, id)
    changeset = Meal.changeset(meal)
    render(conn, "edit.html", meal: meal, changeset: changeset)
  end

  def update(conn, %{"id" => id, "meal" => meal_params}) do
    meal = Fitcrm.Repo.get!(Meal, id)
    changeset = Meal.changeset(meal, meal_params)

    case Fitcrm.Repo.update(changeset) do
      {:ok, meal} ->
        conn
        |> put_flash(:info, "Meal updated successfully.")
        |> redirect(to: meal_path(conn, :show, meal))
      {:error, changeset} ->
        render(conn, "edit.html", meal: meal, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    meal = Fitcrm.Repo.get!(Meal, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Fitcrm.Repo.delete!(meal)

    conn
    |> put_flash(:info, "Meal deleted successfully.")
    |> redirect(to: meal_path(conn, :index))
  end
end

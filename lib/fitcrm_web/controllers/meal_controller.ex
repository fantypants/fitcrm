defmodule FitcrmWeb.MealController do
  use FitcrmWeb, :controller
  import Plug.Conn
    import Ecto.Query
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
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "index.html", meals: meals, changeset: changeset)
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

  def insertMeal(conn, %{"meal" => meal}) do
    does_meal_exist(conn, meal)
  end

  def insert_new_Meal(conn, meal) do
    changeset_params = meal |> IO.inspect
    changeset = Meal.changeset(%Meal{}, changeset_params)
    case Fitcrm.Repo.insert(changeset) do
      {:ok, changeset} ->
        IO.puts "Meals inserted"
        conn
           |> put_flash(:info, "Meal created successfully.")
          |> redirect(to: meal_path(conn, :index))
        {:error, changeset} ->
          IO.puts "Error inserting meal"
          IO.inspect changeset
          conn
             |> put_flash(:info, "Meal created successfully.")
            |> redirect(to: meal_path(conn, :index))

    end
  end

  def updateMeal(conn, meal_old, meal_new) do
    meal = Fitcrm.Repo.get!(Meal, meal_old.id)
    changeset = Meal.changeset(meal, meal_new)
    case Fitcrm.Repo.update changeset do
      {:ok, changeset} ->
        IO.puts "Meals inserted"
        conn
           |> put_flash(:info, "Meal created successfully.")
          |> redirect(to: meal_path(conn, :index))
        {:error, changeset} ->
          IO.puts "Error inserting meal"
          IO.inspect changeset
          conn
             |> put_flash(:info, "Meal created successfully.")
            |> redirect(to: meal_path(conn, :index))

    end
  end

  defp does_meal_exist(conn, meal) do
    query = from m in Meal, where: m.name == ^meal.name
    exists? = Fitcrm.Repo.all(query)
    case exists? do
      [] ->
        IO.puts "New"
        insert_new_Meal(conn, meal)
      _->
      IO.puts "Old"
      exists? |> Enum.map(fn(a) -> updateMeal(conn, a, meal) end)
    end
  end

  def new(conn, _params) do
    changeset = Meal.changeset(%Meal{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"meal" => meal_params}) do
    #changeset = Meal.changeset(%Meal{}, meal_params)

      if upload = meal_params["file"] do
         # PROCESS CSV
         changeset = Accounts.change_user(%Accounts.User{})
         meal = Tools.Io.csvimport_meal(conn, meal_params)
         #insertMeal(%{"meal" => meal})
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
    render(conn, "index.html", meals: meals, changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    meal = Fitcrm.Repo.get!(Meal,id)
    foodids = meal.foodid
    changeset = Accounts.change_user(%Accounts.User{})
    foods = foodids |> Enum.map(fn(a) -> %{name: Fitcrm.Repo.get!(Food, a).name, p: Fitcrm.Repo.get!(Food, a).protein, c: Fitcrm.Repo.get!(Food, a).carbs, f: Fitcrm.Repo.get!(Food, a).fat, cal: Fitcrm.Repo.get!(Food, a).calories, q: Fitcrm.Repo.get!(Food, a).quantity}  end)
    render(conn, "show.html", meal: meal, foods: foods, changeset: changeset)
  end

  def createmeal(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    foods = Fitcrm.Repo.all(Food) |> Enum.map(fn(a) -> %{name: a.name,
    id: a.id,
    p: a.protein,
    c: a.carbs,
    f: a.fat,
    cal: a.calories,
    q: a.quantity}
  end)

    changeset = Meal.changeset(%Meal{}, _params)
    render(conn, "newmeal.html", changeset: changeset, foods: foods)
  end

  def edit(conn, %{"id" => id}) do
    meal = Fitcrm.Repo.get!(Meal, id)
    foods = Fitcrm.Repo.all(Food) |> Enum.map(fn(a) -> %{name: a.name,
    id: a.id,
    p: a.protein,
    c: a.carbs,
    f: a.fat,
    cal: a.calories,
    q: a.quantity}
  end)
    foodids = meal.foodid
    currentfoods = foodids |> Enum.map(fn(a) -> %{name: Fitcrm.Repo.get!(Food, a).name,
    id: a,
    p: Fitcrm.Repo.get!(Food, a).protein,
    c: Fitcrm.Repo.get!(Food, a).carbs,
    f: Fitcrm.Repo.get!(Food, a).fat,
    cal: Fitcrm.Repo.get!(Food, a).calories,
    q: Fitcrm.Repo.get!(Food, a).quantity}
  end)
    changeset = Meal.changeset(meal)
    render(conn, "edit.html", meal: meal, changeset: changeset, foods: foods, currentfoods: currentfoods)
  end

  def update(conn, %{"id" => id, "meal" => meal_params}) do
    IO.inspect meal_params
    name = %{"name" => Map.fetch!(meal_params, "name")} |> IO.inspect
    foods = meal_params |> Map.delete("name") |> Enum.map(fn(a) -> String.to_integer(elem(a, 1)) end) |> IO.inspect
    foodids = %{"foodid" => foods} |> IO.inspect
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

  def insertnewmeal(conn, %{"meal" => meal_params}) do
    name = %{"name" => Map.fetch!(meal_params, "name")}
    type = %{"type" => Map.fetch!(meal_params, "type")}
    rawfoods = meal_params |> Map.delete("name") |> Map.delete("type")
    elemmap = rawfoods |> Enum.map(fn(a) -> a end)
    foodid = elemmap |> Enum.map(fn({k, v}) -> stripFood("id", k) end) |> Enum.reject(fn(a) -> keepID(a) !== true end)
    foodmaps = foodid |> Enum.map(fn(a) ->
      Enum.chunk_by(rawfoods, fn(b) -> elem(b, 0) end)
    end)
    foodmapraw = for {k, v} <- Enum.group_by(rawfoods, fn {k, _} -> hd(Regex.run(~r/\d+$/, k)) end),do: {k, Map.new(v)}
    foodmapsfinal = foodmapraw |> Enum.map(fn({k, v}) -> gatherfooddetails(v) end)

  conn  |> redirect(to: meal_path(conn, :show, 1))
  end

  def insert_and_return_meal(conn, %{"meal" => meal_params}) do
    changeset = Meal.changeset(%Meal{}, meal_params)
    case Fitcrm.Repo.insert(changeset) do
      {:ok, meal} ->
        conn
        |> put_flash(:info, "Meal created successfully.")
        |> redirect(to: meal_path(conn, :show, 1))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def gatherfooddetails(map) do
    elemmap = map |> Enum.map(fn(a) -> a end)
    IO.puts "NAME"
    name = elemmap |> Enum.filter(fn({k, v}) -> k == "name"<>stripFood("name",k) end)
    IO.inspect name
    IO.puts "Carbs"
    carbs = elemmap |> Enum.filter(fn({k, v}) -> k == "carbs"<>stripFood("carbs", k) end)
    IO.puts "fat"
    fat = elemmap |> Enum.filter(fn({k, v}) -> k == "fat"<>stripFood("fat",k) end)
    IO.puts "prot"
    protien = elemmap |> Enum.filter(fn({k, v}) -> k == "prot"<>stripFood("prot", k) end)
    IO.inspect protien
    foods = %{"protien" => elem(List.first(protien), 1), "carbs" => elem(List.first(carbs), 1), "fat" => elem(List.first(fat), 1), "name" => elem(List.first(name), 1)}
    IO.inspect foods

  end

  def stripFood(type, value) do
    case type do
      "name" ->
        String.split(value, "name") |> List.last
      "cals" ->
        String.split(value, "cals") |> List.last
      "prot" ->
        String.split(value, "prot") |> List.last
      "fat" ->
        String.split(value, "fat") |> List.last
      "carbs" ->
        String.split(value, "carbs") |> List.last
      "id" ->
        String.replace_prefix(value, "name", "")
    end
  end

  def keepID(value) do
    Regex.match?(~r/^[0-9]/, value) |> IO.inspect
  end


  def delete(conn, %{"id" => id}) do
    meal = Fitcrm.Repo.get!(Meal, id)
    meals = Repo.all(Meal)


    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Fitcrm.Repo.delete!(meal)

    conn
    |> put_flash(:info, "Meal deleted successfully.")
    |> render(conn, "index.html", meals: meals)
  end
end

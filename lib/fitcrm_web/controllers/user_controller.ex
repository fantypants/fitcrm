defmodule FitcrmWeb.UserController do
  use FitcrmWeb, :controller
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

  # the following plugs are defined in the controllers/authorize.ex file
  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, _) do
    users = Accounts.list_users()
    foods = Fitcrm.Repo.all(Food)
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "index.html", users: users, foods: foods, changeset: changeset)
  end

  def foodindex(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    foods = Fitcrm.Repo.all(Food) |> IO.inspect
    users = Accounts.list_users()
    user = (id == to_string(user.id) and user) || Accounts.get(id)
    changeset = Food.changeset(%Food{}, %{name: "test"})
    render(conn, "foodindex.html", foods: foods, users: users, changeset: changeset, user: user)
  end

  defp user_state(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    IO.puts "checking the user states"
    user = (id == to_string(user.id) and user) || Accounts.get(id)
    #Get Struct data to check
    tdee? = user |> Map.fetch!(:tdee) |> IO.inspect
    case tdee? do
      nil ->
        IO.puts "Not setup"
        #Redirect to Client Setup
        :new
      KeyError ->
        IO.puts "Not setup"
        #Redirect to Client Setup
        :new
      _->
      IO.puts "Client succesfully onboarded"
      #Setup already -- don't do anything
      :exists
    end
  end


  def newquestion(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    changeset = User.changeset(%User{}, %{name: "name"})
    user = (id == to_string(user.id) and user) || Accounts.get(id)
    #params = %{"weight" => "0", "age" => "0", "height" => "0", "sex" => "Male", "activity" => "Sedentary", "cystic" => "No"}
    render(conn, "questionform.html", changeset: changeset, user: user)
  end

  def question(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id, "user" => params}) do
    IO.puts "form question working"
    IO.inspect conn
    changeset = User.changeset(%User{}, %{name: "name"})
    users = Accounts.list_users()
    user = (id == to_string(user.id) and user) || Accounts.get(id)
        changesetmap = ClientTool.onboardclient(%{"user" => user, "params" => params})
        case Accounts.update_user(user, changesetmap) do
          {:ok, user} ->
            WeekdayController.create_week(conn)
            success(conn, "User updated successfully", user_path(conn, :show, user))
          {:error, %Ecto.Changeset{} = changeset} ->
            IO.inspect changeset
            render(conn, "edit.html", user: user, changeset: changeset)
        end
  render(conn, "show.html", user: user, changeset: changeset)
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
    IO.puts "In food insert"
    changeset_params = food |> IO.inspect
    changeset = Food.changeset(%Food{}, changeset_params)
    Fitcrm.Repo.insert!(changeset)
  end

  def updatefood(id, meal) do
    IO.puts "In food insert"
    food = Fitcrm.Repo.get!(Food, id)
    food = Ecto.Changeset.change food, meal_id: String.to_integer(meal)
    Fitcrm.Repo.update! food
    case Fitcrm.Repo.update food do
      {:ok, struct}       ->
        IO.puts "updated"# Updated with success
      {:error, changeset} ->
        IO.puts "Error"
    end
  end


  def new(conn, _) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})
        success(conn, "User created successfully", session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = (id == to_string(user.id) and user) || Accounts.get(id)

    changeset = Food.changeset(%Food{}, %{name: "test"})
    #tdee = user.tdee
    option = Fitcrm.Repo.all(Week) |> Enum.empty? |> IO.inspect
    case option do
      false ->
        plan = "Generated"
      true ->
        plan = "Not Generated"
    end
    subscription = %{type: "Test", status: "Active", plan: plan}
    render(conn, "show.html", user: user, changeset: changeset, subscription: subscription)
  end

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    IO.inspect user_params

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        success(conn, "User updated successfully", user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end


  defp checkExistingPlan(user_id) do
    # This checks for a result in the db for the users plan
    query = from w in Week, where: w.user_id == ^user_id
    onboard? = Fitcrm.Repo.all(query) |> Enum.empty?
    case onboard? do
      false ->
        {:valid, "Client has already onboarded"}
      true ->
        {:onboard, "Client hasn't onboarded"}
    end
  end

  def onboardProcess(conn, user_id) do
    IO.puts "Onboarding Client #{user_id}"
    # client logs in
    # This checks if the client has a subscription
    # For each subscription it checks the necessary plan to see if it's created
    exists? = checkExistingPlan(user_id)
    case exists? do
      {:valid, payload} ->
        :valid
      {:onboard, payload} ->
        :onboard
    end
  end

  def setup(conn, %{"id" => id}) do
    # Get the total query and see if it exists
    query = from w in Week, where: w.user_id == ^id, select: w.id
    w_whole = Fitcrm.Repo.all(query)
    option = w_whole |> Enum.empty?
    user = Fitcrm.Repo.get!(User, id)
    question = Fitcrm.Repo.get!(User, id).tdee
    case question do
      nil ->
        i_stage = 0
        question_stat = "Not Completed"
      _->
      question_stat = "Completed"
      case option do
        nil ->
          FitcrmWeb.WeekdayController.create_week(conn)
          i_stage = 1
        _->
          i_stage = 1
      end
    end

    case i_stage do
      0 ->
        stage = 1
      1 ->
        stage = 2
    end

    case stage do
      1 -> user_setup = "question"
      2 -> user_setup = "complete"
    end

    case user_setup do
      "question" ->
          IO.puts "Do nothing"
          plan_stat = "Not Generated"
          week_id = "0"
          week = "Not generated"
      "complete"->
         week_id = List.first(w_whole)
         week = Fitcrm.Repo.get!(Week, week_id)
         plan_stat = "Plan has been generated"
    end
    IO.inspect user_setup

    status = %{
      plan: plan_stat,
      question: question_stat}

      changeset = Accounts.change_user(%Accounts.User{})
    conn |> render("setup.html", user: user, week: week, status: status, user_setup: user_setup, changeset: changeset)
  end

  def deletefood(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    food = Fitcrm.Repo.get!(Food, id)
    users = Accounts.list_users()
    foods = Fitcrm.Repo.all(Food)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Fitcrm.Repo.delete!(food)

    conn
    |> put_flash(:info, "Meal deleted successfully.")
    |> index(user: users, foods: foods)
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    {:ok, _user} = Accounts.delete_user(user)

    delete_session(conn, :phauxth_session_id)
    |> success("User deleted successfully", session_path(conn, :new))
  end
end

defmodule FitcrmWeb.UserController do
  use FitcrmWeb, :controller
  alias Bamboo.SentEmailViewerPlug
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
  alias Fitcrm.Plan.Workout
  alias FitcrmWeb.WeekdayController
  alias Fitcrm.Tools.UserTool
  alias Fitcrm.Plan.Weekday
  alias Fitcrm.Foods.Meal

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
    ages = [
    "10", "11", "12","13", "14", "15", "16", "17", "18", "19",
    "20", "21", "22","23", "24", "25", "26", "27", "28", "29",
    "30", "31", "32","33", "34", "35", "36", "37", "38", "39",
    "40", "41", "42","43", "44", "45", "46", "47", "48", "49",
    "50", "51", "52","53", "54", "55", "56", "57", "58", "59",
    "60", "61", "62","63", "64", "65", "66", "67", "68", "69",
    "70", "71", "72","73", "74", "75", "76", "77", "78", "79",
    "80", "81", "82","83", "84", "85", "86", "87", "88", "89",
    "90", "91", "92","93", "94", "95", "96", "97", "98", "99"]
    types = Fitcrm.Repo.all(Workout) |> Enum.map(&(&1.type)) |> IO.inspect
    levels = Fitcrm.Repo.all(Workout) |> Enum.map(&(&1.level)) |> IO.inspect
    workouts = Fitcrm.Repo.all(Workout) |> Enum.map(fn(a) -> %{full: a.type <> "/" <> a.level, type: a.type, level: a.level, id: a.id} end) |> IO.inspect
    #params = %{"weight" => "0", "age" => "0", "height" => "0", "sex" => "Male", "activity" => "Sedentary", "cystic" => "No"}
    render(conn, "questionform.html", changeset: changeset, user: user, types: types, levels: levels, workouts: workouts, ages: ages)
  end

  def question(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id, "user" => params}) do
    IO.puts "Question Form Submission"
    IO.inspect params
    #SET THE PARAMS FOR THE WORKOUT
    changeset = User.changeset(%User{}, %{name: "name"})
    users = Accounts.list_users()
    user = (id == to_string(user.id) and user) || Accounts.get(id)
    formchangeset = User.formchangeset(%User{}, params) |> IO.inspect


       changesetmap = ClientTool.onboardclient(%{"user" => user, "params" => params})
       case Accounts.update_user(user, changesetmap) do
         {:ok, user} ->
           #ADD OR HERE
           WeekdayController.check_exists(conn)
           success(conn, "User updated successfully", user_path(conn, :show, id))
         {:error, %Ecto.Changeset{} = changeset} ->
           IO.inspect changeset
           render(conn, "edit.html", user: user, changeset: changeset)
       end
  end

  def reset_password(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    changeset = User.changeset(%User{}, %{name: "name"})
    Tools.Email.welcome_email |> Tools.Mailer.deliver_now |> IO.inspect
      #case Phauxth.Confirm.verify(params, Accounts, mode: :pass_reset) do
      #  {:ok, user} ->
      #    Accounts.update_password(user, params)
      #    |> handle_password_reset(conn, params)
      #  {:error, message} ->
    #      handle_error()
    #  end
    render(conn, "resetpassword.html", changeset: changeset)
  end

def view_emails(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
changeset = User.changeset(%User{}, %{name: "name"})
emails = Bamboo.SentEmail.all |> IO.inspect |> Enum.map(fn(a) -> %{from: elem(a.from, 1), to: elem(List.first(a.to), 1), subject: a.subject} end) |> IO.inspect
render(conn, "viewemails.html", changeset: changeset, emails: emails)
end

def passwordreset(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => %{"email" => email}}) do
changeset = User.changeset(%User{}, %{name: "name"})

case Tools.UserTool.check_user(email) do
  {:ok, user} ->
    #Accounts.update_password(user, params)
    #|> handle_password_reset(conn, params)
    case Tools.UserTool.retrieve_password do
      {:ok, password} ->
        IO.puts "updating password"
        case Accounts.update_user(List.first(user), %{"email" => email, "password" => password}) do
          {:ok, user} ->
            Tools.Email.password_recovery(email, password) |> Tools.Mailer.deliver_now
            render(conn, "resetpassword.html", changeset: changeset)
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "resetpassword.html", changeset: changeset)
        end
        IO.puts "Send Email"
      {:error, message} ->
        IO.puts "Password Change Failed"
        render(conn, "resetpassword.html", changeset: changeset)
      end
  {:error, message} ->
      IO.puts "Error"
      IO.inspect message
      render(conn, "resetpassword.html", changeset: changeset)
  end
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
  def ingredients(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    week = Fitcrm.Repo.all(from w in Week, where: w.user_id == ^id, select: w.id)
    days = week |> Enum.map(fn(a)-> getday(a) end)
    bfoods = days |> List.flatten |> Enum.map(fn(a) -> getmeal(a.b) end) |> Enum.map(fn(a) -> getfood(a) end)
    bfoods_whole = countIngredients(bfoods) |> Enum.map(fn(a) -> sortFood(a) end)
    lfoods = days |> List.flatten |> Enum.map(fn(a) -> getmeal(a.l) end) |> Enum.map(fn(a) -> getfood(a) end)
    lfoods_whole = countIngredients(lfoods) |> Enum.map(fn(a) -> sortFood(a) end)
    dfoods = days |> List.flatten |> Enum.map(fn(a) -> getmeal(a.d) end) |> Enum.map(fn(a) -> getfood(a) end)
    dfoods_whole = countIngredients(dfoods) |> Enum.map(fn(a) -> sortFood(a) end)
    foods = bfoods_whole ++ lfoods_whole ++ dfoods_whole
    changeset = Accounts.change_user(user)
    render(conn, "ingredients.html", foods: foods, changeset: changeset, user: user)
  end

  def getday(weekid) do
    IO.inspect weekid
    query = from w in Weekday, where: w.week_id ==^weekid
    day = Fitcrm.Repo.all(query) |> Enum.map(fn(a) -> %{day: a.day, b: a.breakfast, l: a.lunch, d: a.dinner} end)
    day
  end

  def getmeal(id) do
    query = from m in Meal, where: m.id ==^id
    food = Fitcrm.Repo.all(query) |> Enum.map(fn(a) -> a.foodid end) |> List.flatten
  end

  def getfood(id) do
    id |> Enum.map(fn(a) -> %{name: Fitcrm.Repo.get!(Food, a).name, quantity: Fitcrm.Repo.get!(Food, a).quantity} end)
  end

  def countIngredients(map) do
    map
    |> List.flatten
    |> Enum.map(fn(ingred) ->
      {key, n} = case Regex.run(~r/^(?<qty>[.0-9]+)\s*(?<unit>\w+)?$/, ingred.quantity, capture: :all_but_first) do
        [n, unit] -> {{ingred.name, unit}, n}
        [n] -> {ingred.name, n}
      end
      {f, ""} = Float.parse(n)
      {key, f}
    end)|> Enum.group_by(&elem(&1, 0), &elem(&1, 1))|> Map.new(fn({k,vs}) -> {k, Enum.sum(vs)} end)
  end
  def randomfunction(data) do
    IO.inspect data
  end
  def sortFood(map) do
    IO.inspect map
    case map do
      {{food, unit}, quantity} ->
        inner = elem(map,0)
        quantity = elem(map, 1)
        name = elem(inner, 0)
        unit = elem(inner, 1)
      {food, quantity} ->
        name = food
        quantity = elem(map, 1)
        unit = "Whole"
    end
    %{name: name, unit: unit, quantity: quantity}
  end



  def new(conn, _) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})
        case user_params["refemail"] do
          nil ->
            success(conn, "User created successfully", session_path(conn, :new))
          _->
            UserTool.ref_controller(conn, user.id, user_params["refemail"])
            success(conn, "User created successfully", session_path(conn, :new))
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = (id == to_string(user.id) and user) || Accounts.get(id)

    changeset = Food.changeset(%Food{}, %{name: "test"})
    referrals_1 = Fitcrm.Repo.get!(User, id).ref_id |> IO.inspect
    ref = Fitcrm.Repo.get!(User, id) |> IO.inspect
    case referrals_1 do
      nil ->
        referrals = ["None"]
      _->
      referrals = Enum.map(referrals_1, fn(a) -> %{name: Fitcrm.Repo.get!(User, a).name, email: Fitcrm.Repo.get!(User, a).email} end)
    end
    #tdee = user.tdee
    option = Fitcrm.Repo.all(Week) |> Enum.empty? |> IO.inspect
    case option do
      false ->
        plan = "Generated"
      true ->
        plan = "Not Generated"
    end
    subscription = %{type: "Test", status: "Active", plan: plan}
    render(conn, "show.html", user: user, changeset: changeset, subscription: subscription, referrals: referrals)
  end

  def api_profile(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    user = Fitcrm.Repo.get!(User, user.id)

    conn |> render("user.json", %{user: user})

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
    IO.puts "User ID is"
    IO.inspect id
    # Get the total query and see if it exists
    query = from w in Week, where: w.user_id == ^id, select: w.id
    w_whole = Fitcrm.Repo.all(query) |> IO.inspect
    option = w_whole |> Enum.empty?
    user = Fitcrm.Repo.get!(User, id)
    question = Fitcrm.Repo.get!(User, id).tdee

    case w_whole do
      [] ->
        i_stage = 0
      _->
        i_stage = 1
    end

    case question do
      nil ->
        i_stage = 0
        question_stat = "Not Completed"
      _->
      question_stat = "Completed"
      case option do
        nil ->
          case w_whole do
            [] ->
              i_stage = 0
            _->
              FitcrmWeb.WeekdayController.create_week(conn)
              i_stage = 1
          end
        _->
        case w_whole do
          [] ->
          i_stage = 0
          _->
          i_stage = 1
      end
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


  def update_list(conn, user_id, new_list) do
    user = Fitcrm.Repo.get!(User, user_id)
    user_params = %{"ref_id" => new_list}
    changeset = User.changeset(user, user_params)

    case Fitcrm.Repo.update(changeset) do
      {:ok, user} ->
        IO.puts "Updated Succesfully"
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect changeset
        render(conn, "edit.html", user: user, changeset: changeset)
    end
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

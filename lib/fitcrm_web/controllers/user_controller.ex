defmodule FitcrmWeb.UserController do
  use FitcrmWeb, :controller
  alias Fitcrm.Foods.Food
  import FitcrmWeb.Authorize
  alias Phauxth.Log
  alias Fitcrm.Accounts
  alias Fitcrm.Tools
  alias Fitcrm.Accounts.User

  # the following plugs are defined in the controllers/authorize.ex file
  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, _) do
    users = Accounts.list_users()
    foods = Fitcrm.Repo.all(Food)
    render(conn, "index.html", users: users, foods: foods)
  end

  defp calculate_tdee(%{"sex" => sex, "height" => height, "mass" => mass, "activity" => activity, "age" => age}) do
    case sex do
      "Male" ->
        bmr = 66 + (13.7 * mass) +(5 * height) - (6.8 * age)
      "Female" ->
        bmr = 655 + (9.6 * mass) +(1.8 * height) - (4.7 * age)
    end
    bmr
  end

  defp scaleActivity(bmr, activity) do
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

  def newquestion(conn, %{"id" => id}) do
    changeset = User.changeset(%User{}, %{name: "name"})
    params = %{"mass" => 0, "weight" => 0, "age" => 0, "height" => 0, "sex" => "male", "activity" => 0}
    question(conn, %{"id" => id, "user" => params})
  end

  def question(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id, "user" => params}) do
    IO.puts "form question working"
    IO.inspect conn
    changeset = User.changeset(%User{}, %{name: "name"})
    users = Accounts.list_users()
    user = (id == to_string(user.id) and user) || Accounts.get(id)

# Question Params
  #need to work out how to prevent ill submitted forms
    weight = params["mass"]
    height = params["height"]
    activity = params["activity"] #|> String.to_integer
    age = params["age"] #|> String.to_integer
    sex = params["sex"]
    cystic = params["cystic"]
   params_new = modifyQuestionResults(%{"sex" => sex, "height" => height, "mass" => weight, "activity" => activity, "age" => age, "cystic" => cystic}) |> IO.inspect

    bmr = calculate_tdee(params_new) |> IO.inspect
    tdee = scaleActivity(bmr, params_new["activity"]) |> IO.inspect
# End Result
# Now push result into DB

#user_params = %{"age" => age, "sex" => sex, "weight" => weight, "height" => height, "activity" => activity, "bmr" => bmr, "tdee" => tdee}

#case Accounts.update_user(user, user_params) do
#  {:ok, user} ->
#    success(conn, "User updated successfully", user_path(conn, :show, user))

#  {:error, %Ecto.Changeset{} = changeset} ->
#    render(conn, "edit.html", user: user, changeset: changeset)
#end



    render(conn, "questionform.html", changeset: changeset, users: users, user: user)
  end

  defp modifyQuestionResults(%{"sex" => s, "height" => h, "mass" => w, "activity" => act, "age" => a, "cystic" => c}) do
    case act do
      "Sedentary" ->
        nact = 0
      "Light"
        nact = 1
      "Moderate"
        nact = 2
      "Heavy"
        nact = 3
      "Athlete"
        nact = 4
    end
    weight = w |> convert |> elem(0)
    height = h |> convert |> elem(0)
    age = a |> String.to_integer
    nact
    %{"sex" => s, "height" => height, "mass" => weight, "activity" => nact, "age" => age}
  end

  defp convert(val) do
    case val do
      "" ->
        ""
      _->
      Float.parse(val)
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
    conn
    |> render("show.html", users: users, user: user, changeset: changeset)
  end

  def insertfoods(%{"food" => food}) do
    changeset_params = food |> IO.inspect
    changeset = Food.changeset(%Food{}, changeset_params)
    Fitcrm.Repo.insert!(changeset)
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

    render(conn, "show.html", user: user, changeset: changeset)
  end

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        success(conn, "User updated successfully", user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    {:ok, _user} = Accounts.delete_user(user)

    delete_session(conn, :phauxth_session_id)
    |> success("User deleted successfully", session_path(conn, :new))
  end
end

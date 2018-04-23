defmodule FitcrmWeb.ApiController do
  use FitcrmWeb, :controller
  alias FitcrmWeb.ApiController
  import Plug.Conn
  import FitcrmWeb.Router.Helpers
  import Phoenix.Controller
  import FitcrmWeb.Authorize
  alias Fitcrm.Foods.Meal
  alias Fitcrm.Foods.Food
  alias Phauxth.Log
  alias Fitcrm.Accounts
  alias Fitcrm.Tools
  alias Fitcrm.Accounts.User
  alias Fitcrm.Tools.ClientTool
  alias FitcrmWeb.SessionController
  plug :user_check when action in [:authenticate]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, _params) do
     users = Fitcrm.Repo.all(User)
     render(conn, "index.json", users: users)
   end

  def authenticate(conn, %{"email" => email, "password" => password}) do
    user_params = %{"email" => email, "password" => password}
    session_params = %{"session" => user_params}
    SessionController.create(conn, session_params) |> IO.inspect


    render(conn, "authenticate.json", user_params: user_params)
  end

end

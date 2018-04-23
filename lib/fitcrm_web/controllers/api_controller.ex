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

  def index(conn, params) do
     users = Fitcrm.Repo.all(User)
     render(conn, "authenticated.json", params: params)
   end

  def authenticate(conn, %{"email" => email, "password" => password}) do
    user_params = %{"email" => email, "password" => password}
    session_params = %{"session" => user_params}
    scrubbed_params = %{"email" => email, "password" => ""}
    authenticated? = SessionController.create_api(conn, session_params) |> IO.inspect
    case authenticated? do
      {:success, user} ->
        render(conn, "authenticated.json", %{"params" => %{"email" => user.email, "name" => user.name}})
      _->
        render(conn, "authenticate.json", user_params: scrubbed_params)
  end
end

end

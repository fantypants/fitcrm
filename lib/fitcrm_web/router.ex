defmodule FitcrmWeb.Router do
  use FitcrmWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug(Phauxth.Authenticate, method: :token)
  end

  scope "/", FitcrmWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController do
      resources "/weekdays", WeekdayController
      get "/weeks/:week_id", WeekdayController, :showweek
      get "/weekindex", WeekdayController, :weekindex
      get "/admindash", PageController, :admindash
    end
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/meals", MealController
    resources "/workouts", WorkoutController
    resources "/weekdays", WeekdayController
    get "users/:id/csvupload", UserController, :csvupload
    post "users/:id/csvupload", UserController, :csvupload
    get "users/:id/question", UserController, :question
    get "users/:id/newquestion", UserController, :newquestion
    post "users/:id/newquestion", UserController, :newquestion
    post "users/:id/question", UserController, :question
    get "users/:id/foods", UserController, :foodindex
    post "users/:id/foods", UserController, :foodindex
    get "users/:id/foods/deletefood", UserController, :deletefood
    post "users/:id/foods/deletefood", UserController, :deletefood
    get "users/:id/setup", UserController, :setup
    put "users/:id/setup", UserController, :setup


  end

  scope "/api", FitcrmWeb do
    pipe_through :api
    get "/", ApiController, :index
    get "/authenticate", ApiController, :authenticate
    post "/authenticate", ApiController, :authenticate
    get "/status", StatusController, :index
end

scope "/api/v1" do
  pipe_through :api
  get "/sessions", FitcrmWeb.SessionController, :create_api_v1
  get "/users", FitcrmWeb.UserController, :api_profile
  get "/weeks/:week_id", FitcrmWeb.WeekdayController, :jsonweek
  #post "/sessions/create_api", FitcrmWeb.SessionController, :create_api
  #get "/sessions/create_api", FitcrmWeb.SessionController, :create_api
end

def check_admin_metadata(conn, opts) do
  claims = Map.get(conn.assigns, :joken_claims)
  case Map.get(claims, "app_metadata") do
    %{"role" => "admin"} ->
      assign(conn, :admin, true)
    _ ->
      conn
      |> forbidden
  end
end

@doc """
send 403 to client
"""
def forbidden(conn) do
  msg = %{
    errors: %{
      details: "forbidden resource"
    }
  }
  conn
  |> put_resp_content_type("application/json")
  |> send_resp(403, Poison.encode!(msg))
  |> halt
end

# create a new pipeline for admin: web/router.ex
pipeline :api_admin do
  plug :check_admin_metadata
end

# add a new scope
scope "/api/admin", Fitcrm do
  pipe_through [:api, :api_admin]

  get "/", StatusController, :admin
end


end

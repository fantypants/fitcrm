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
end

end

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

  scope "/", FitcrmWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController
    get "users/:id/csvupload", UserController, :csvupload
    post "users/:id/csvupload", UserController, :csvupload
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

end

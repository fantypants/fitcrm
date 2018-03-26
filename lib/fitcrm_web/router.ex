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
    resources "/users", UserController do
      get "/csvupload", UserController, :csvupload
      post "/csvupload", UserController, :csvupload
    end
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

end

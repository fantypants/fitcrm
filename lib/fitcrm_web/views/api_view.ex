defmodule FitcrmWeb.ApiView do
  use FitcrmWeb, :view

  def render("authenticated.json", %{"params" => params}) do
    #params = %{email: "this", password: "that"}
    #%{data: render_many(users, FitcrmWeb.ApiView, "user.json")}
    %{
      email: params["email"],
      name: params["name"]
    }
  end



  def render("show.json", %{users: users}) do
    %{data: render_one(users, FitcrmWeb.ApiView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      email: user.email,
      name: user.name
    }
  end



  def render("authenticate.json", %{user_params: user_params}) do
    IO.puts "Rendering Login"
    IO.inspect user_params
    #%{email: user_params.email,password: user_params.password}
  end

  def render("show.json", %{user_params: user_params}) do
    IO.puts "Rendering Login -- Show"
    IO.inspect user_params
    %{data: render_one(user_params, FitcrmWeb.ApiView, "login.json")}
  end

  def render("login.json", %{user_param: user_param}) do
    IO.puts "Renderign actual login page"
    IO.inspect user_param
    %{
      uuid: user_param.email,
      uuid2: user_param.email
    }
  end



end

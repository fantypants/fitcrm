defmodule FitcrmWeb.UserView do
  use FitcrmWeb, :view
  alias FitcrmWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    IO.puts "Rendering User Profile"
    %{id: user.id,
      email: user.email, name: user.name}
  end
end

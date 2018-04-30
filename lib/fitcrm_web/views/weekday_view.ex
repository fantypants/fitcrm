defmodule FitcrmWeb.WeekdayView do
  use FitcrmWeb, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("week.json", %{week: week}) do
    IO.puts "Rendering User Profile"
    %{id: week.id, days: week.days}
  end
end

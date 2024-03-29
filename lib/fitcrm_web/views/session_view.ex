defmodule FitcrmWeb.SessionView do
  use FitcrmWeb, :view

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end

  def render("logout.json", %{message: message}) do
    %{message: message}
  end


  def render("info.json", %{info: token}) do
    %{access_token: token}
  end

end

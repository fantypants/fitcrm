defmodule FitcrmWeb.PageController do
  use FitcrmWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

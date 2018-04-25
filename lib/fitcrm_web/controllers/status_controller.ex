defmodule FitcrmWeb.StatusController do
  use FitcrmWeb, :controller

  def index(conn, _params) do
    status = %{
      success: true
    }
    render(conn, "status.json", status: status)
  end


def admin(conn, _params) do
  status = %{
    success: true,
    role: "admin"
  }
  render(conn, "status.json", status: status)
end
end

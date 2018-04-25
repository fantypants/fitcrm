defmodule FitcrmWeb.StatusView do
  use FitcrmWeb, :view

  def render("status.json", %{status: status}) do
    status
  end
end

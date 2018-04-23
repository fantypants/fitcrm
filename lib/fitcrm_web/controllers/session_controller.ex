defmodule FitcrmWeb.SessionController do
  use FitcrmWeb, :controller

  import FitcrmWeb.Authorize
  alias Fitcrm.Accounts
  alias Phauxth.Login
  alias FitcrmWeb.UserController

  plug :guest_check when action in [:new, :create]
  plug :id_check when action in [:delete]

  def new(conn, _) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "new.html", changeset: changeset)
  end

  # If you are using Argon2 or Pbkdf2, add crypto: Comeonin.Argon2
  # or crypto: Comeonin.Pbkdf2 to Login.verify (after Accounts)
  def create(conn, %{"session" => params}) do
    case Login.verify(params, Accounts, crypto: Comeonin.Argon2) do
      {:ok, user} ->
        session_id = Login.gen_session_id("F")
        Accounts.add_session(user, session_id, System.system_time(:second))
        Login.add_session(conn, session_id, user.id)
        |> login_success(user_path(conn, :show, user.id), user.id)

      {:error, message} ->
        error(conn, message, session_path(conn, :new))
    end
  end

  def create_api(conn, %{"session" => params}) do
    case Login.verify(params, Accounts, crypto: Comeonin.Argon2) do
      {:ok, user} ->
        IO.inspect user
        params = %{email: user.email, name: user.name}
        {:success, user}

      {:error, message} ->
        {:error, "Error"}
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    <<session_id::binary-size(17), _::binary>> = get_session(conn, :phauxth_session_id)
    Accounts.delete_session(user, session_id)

    delete_session(conn, :phauxth_session_id)
    |> success("You have been logged out", page_path(conn, :index))
  end
end

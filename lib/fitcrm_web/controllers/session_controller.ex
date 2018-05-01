defmodule FitcrmWeb.SessionController do
  use FitcrmWeb, :controller

  import FitcrmWeb.Authorize
  alias Fitcrm.Accounts
  alias Phauxth.Login
  alias FitcrmWeb.UserController
  alias Fitcrm.Tools.Guardian






  plug :guest_check when action in [:new, :create]
  plug :id_check when action in [:delete]

  def new(conn, _) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "new.html", changeset: changeset)
  end

  # If you are using Argon2 or Pbkdf2, add crypto: Comeonin.Argon2
  # or crypto: Comeonin.Pbkdf2 to Login.verify (after Accounts)
  def create(conn, %{"session" => params}) do
    IO.inspect params
    case Login.verify(params, Accounts, crypto: Comeonin.Argon2) do
      {:ok, user} ->
        session_id = Login.gen_session_id("F")
        Accounts.add_session(user, session_id, System.system_time(:second))
        IO.puts "Login from weird function is"
        Login.add_session(conn, session_id, user.id) |> IO.inspect


       |> login_success(user_path(conn, :show, user.id), user.id)

      {:error, message} ->
        error(conn, message, session_path(conn, :new))
    end
  end

  def create_api(conn, %{"session" => params}) do
    case Login.verify(params, Accounts, crypto: Comeonin.Argon2) do
      {:ok, user} ->
        IO.puts "Got succesful user"
        session_id = Login.gen_session_id("F")
        IO.puts "Session ID is #{session_id}"
          with {:ok, user} <- Accounts.add_session(user, session_id, System.system_time(:second))do
            IO.puts "Success from session add"
            Login.add_session(conn, session_id, user.id)
          end
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        conn |> render("jwt.json", jwt: token)
      {:error, message} ->
        error(conn, message, session_path(conn, :new))
    end
  end







  # If you are using Argon2 or Pbkdf2, add crypto: Comeonin.Argon2
  # or crypto: Comeonin.Pbkdf2 to Login.verify (after Accounts)
  def create_api_v1(conn, %{"session" => params}) do
    IO.puts "Password is #{params["password"]}"
    case Login.verify(params, Accounts, crypto: Comeonin.Argon2) do
      {:ok, user} ->
        token = Phauxth.Token.sign(conn, user.id)
        render(conn, "info.json", %{info: token})
      {:error, _message} ->
        error(conn, :unauthorized, 401)
    end
end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    <<session_id::binary-size(17), _::binary>> = get_session(conn, :phauxth_session_id)
    Accounts.delete_session(user, session_id)

    delete_session(conn, :phauxth_session_id)
    |> success("You have been logged out", page_path(conn, :index))
  end
end

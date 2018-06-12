defmodule Fitcrm.Tools.UserTool do
    alias Fitcrm.Tools.UserTool
    alias Fitcrm.Accounts.User
    alias Fitcrm.Accounts
    import Ecto.Query
    import Plug.Conn
    #Creates User
    #On completion check if the referral is nil
    #If not nil then patch the email through to here
    #Find user from email

    def get_existing_ref(new_user, user_id) do
      IO.puts "Getting existing referrals"
      user_ref = Fitcrm.Repo.get!(User, user_id).ref_id |> IO.inspect
      case user_ref do
        nil ->
          # SHOULD RETURN LISTS
          build_ref(new_user)
        _->
        # SHOULD RETURN LISTS
          add_ref(new_user, user_ref)
      end
    end

    defp build_ref(new_user) do
      IO.puts "Building Referral"
      [new_user]
    end

    defp add_ref(new_user, existing_list) do
      IO.puts "Adding Referral"
      IO.inspect existing_list
      exists? = Enum.find(existing_list, fn(a) -> a == new_user end)
      case exists? do
        nil ->
          existing_list |> List.insert_at(0, new_user)
        _->
          existing_list
      end
    end

    defp get_user_id(email) do
      IO.puts "finding the User"
      query = from u in User, where: u.email == ^email, select: u.id
      user_query = Fitcrm.Repo.all(query)
      case user_query do
        nil ->
          {:error, "No user found"}
          [] ->
            {:error, "No user found"}
        _->
          {:ok, List.first(user_query)}
    end
    end


    def ref_controller(conn, new_user, email) do
      user_id = get_user_id(email)
      case user_id do
        {:error, message} ->
          IO.puts "Error, No users found"
          IO.inspect message
        {:ok, user_id}->
          new_list = get_existing_ref(new_user, user_id)
          FitcrmWeb.UserController.update_list(conn, user_id, new_list)
    end
  end

  def check_user(email) do
    exists? = Fitcrm.Repo.all(from u in User, where: u.email == ^email)
    case exists? do
      nil ->
        {:error, "User Doesn't Exist"}
      _->
      {:ok, exists?}
    end
  end

 def retrieve_password do
   password_new = random_string(8) |> IO.inspect
   {:ok, password_new}
 end

 def random_string(length) do
  :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
end

def update_referrals() do
  IO.puts "Gets exisiting and new referrals"
  query = User
  referrer = Fitcrm.Repo.all(query) |> Enum.map(fn(a) -> %{referrer: a.ref_id, referree: a.id} end)
  |> Enum.reject(fn(b) -> b.referrer == nil end)
end






end

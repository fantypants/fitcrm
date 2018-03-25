# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#

users = [
  %{email: "admin@dbfitness.com", password: "password"},
  %{email: "matthewmjeaton@gmail.com", password: "password"}
]

for user <- users do
  {:ok, _} = Fitcrm.Accounts.create_user(user)
end

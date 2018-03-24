use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :fitcrm, FitcrmWeb.Endpoint,
  secret_key_base: "HKc0f/emQ48T9awBsgNcn1g8ksG+GGmonIjhyZ9Ju/rBW70km6CJGVmALrgaxDRa"

# Configure your database
config :fitcrm, Fitcrm.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "fitcrm_prod",
  pool_size: 15

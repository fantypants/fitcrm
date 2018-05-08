# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :fitcrm,
  ecto_repos: [Fitcrm.Repo]

# Configures the endpoint
config :fitcrm, FitcrmWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4hSwpl2EOm4G+n8NZfFqrwi4JLRlg/Rqc93MY4tZaCvcWEDtInDKk2jXILYDKY84",
  render_errors: [view: FitcrmWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Fitcrm.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Phauxth authentication configuration
config :phauxth,
  token_salt: "P7hD4M65",
  endpoint: FitcrmWeb.Endpoint

# Configures Elixir's Logger
config :logger, :console, level: :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :fitcrm, :auth0,
  app_baseurl: System.get_env("http://localhost:4000/"),
  app_id: System.get_env("1"),
  app_secret: "4hSwpl2EOm4G+n8NZfFqrwi4JLRlg/Rqc93MY4tZaCvcWEDtInDKk2jXILYDKY84"
    |> System.get_env
    |> Kernel.||("")
    |> Base.url_decode64
    |> elem(1)

config :fitcrm, Fitcrm.Guardian,
       issuer: "fitcrm",
       secret_key: "q4ZkRBGyhwmoHy89HU2IjD6+ID3RFMCChBkeGjip4HSEhxE5k3gbEu9yyeKBstCK"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

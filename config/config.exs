# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :mgp,
  ecto_repos: [Mgp.Repo]

# Configures the endpoint
config :mgp, MgpWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1WrpHSu9SdP93NLJgdN8Jlbr1pWo3bIestyBsqogkbMybzD0l+9tvL6m6VJIbFO0",
  render_errors: [view: MgpWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Mgp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

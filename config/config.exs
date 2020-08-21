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
  secret_key_base: "SXOgc3g9jWdaH2OQc9dasOfHeEOrX8Z69ZgHGqqVb9lrlUMrQq8XQS1KXZznS9YW",
  render_errors: [view: MgpWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Mgp.PubSub,
  live_view: [signing_salt: "ZPm2mCgJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

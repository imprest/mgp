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
  secret_key_base: "g5pTn2bDbp7H2+yEfqAk+WQeYXudYgKS5Ypv5ECR+L4HBENXWXtQpmYjGJe1DiiB",
  render_errors: [view: MgpWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Mgp.PubSub,
  live_view: [signing_salt: "a9w5CKKg"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

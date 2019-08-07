use Mix.Config

# Configure your database
config :mgp, Mgp.Repo,
  username: "postgres",
  password: "postgres",
  database: "mgp_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mgp, MgpWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

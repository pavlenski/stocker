import Config

config :testcontainers, enabled: true

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

config :stocker_api, StockerApi.Repo,
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PASSWORD") || "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  port: System.get_env("DB_PORT") || "5432",
  database: "stocker_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# config :stocker_api, StockerApi.Repo,
#   username: "postgres",
#   password: "postgres",
#   # used to be postgres instead of localhost
#   hostname: "postgres",
#   port: "4443",
#   database: "stocker_api_test",
#   pool: Ecto.Adapters.SQL.Sandbox,
#   pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :stocker_api, StockerApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "xdmIC8C/Rv3a+QlnzYyJi4jNk6fmk8rzACP4LdZQsNcaY/zcbL29oa7lSDfZf4j6",
  server: false

# In test we don't send emails
config :stocker_api, StockerApi.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

use Mix.Config

# Configuration for test environment
config :ex_unit, capture_log: true

# Configure your database
config :man, Man.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: {:system, "DB_NAME", "man_test"}

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :man, Man.Web.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :debug

# Run acceptance test in concurrent mode
config :man, sql_sandbox: true

# This requires installing wkhtmltopdf onto developers machine
config :pdf_generator,
    wkhtml_path: "/usr/local/bin/wkhtmltopdf"

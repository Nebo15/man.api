# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :man_api, ecto_repos: [Man.Repo]

config :man_api, auth_host: {:system, "AUTH_HOST", "https://localhost"}

# Configure your database
config :man_api, Man.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: {:system, "DB_NAME", "man_dev"},
  username: {:system, "DB_USER", "postgres"},
  password: {:system, "DB_PASSWORD", "postgres"},
  hostname: {:system, "DB_HOST", "localhost"},
  port: {:system, :integer, "DB_PORT", 5432},
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

# This configuration file is loaded before any dependency and
# is restricted to this project.

config :mime, :types, %{
  "application/pdf" => ["pdf"]
}

# General application configuration
# Configures the endpoint
config :man_api, Man.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BN71lljHhjDJP7n8TnIg4f+slrxjkbbV4wQDh7RervDFLd3bqCD1CE8JA5UW1AY7",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)]

# Cache PDF output that is costly to render
config :man_api, cache_pdf_output: {:system, :boolean, "CACHE_PDF_OUTPUT", false}

# Configures Elixir's Logger
config :logger, :console,
  format: "$message\n",
  handle_otp_reports: true,
  level: :info

# This requires installing wkhtmltopdf onto developers machine
config :pdf_generator, wkhtml_path: "wkhtmltopdf"

config :porcelain, driver: Porcelain.Driver.Basic

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :ehealth_printout, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:ehealth_printout, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
# Or read environment variables in runtime (!) as:
#
#     :var_name, "${ENV_VAR_NAME}"

config :ehealth_printout,
  ecto_repos: [EhealthPrintout.Repo]

# Configure your database
config :ehealth_printout, EhealthPrintout.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: {:system, "DB_NAME", "ehealth_printout_dev"},
  username: {:system, "DB_USER", "postgres"},
  password: {:system, "DB_PASSWORD", "postgres"},
  hostname: {:system, "DB_HOST", "localhost"},
  port: {:system, :integer, "DB_PORT", 5432}
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
# Configures the endpoint
config :ehealth_printout, EhealthPrintout.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BN71lljHhjDJP7n8TnIg4f+slrxjkbbV4wQDh7RervDFLd3bqCD1CE8JA5UW1AY7",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"

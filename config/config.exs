# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :risen, Risen.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "9lfHICFrDR3TqXsGHMdOBUEkIbOh6Xs9jsmBy66HqKxeHYsFdURwoWcA7z9Du8W6",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Risen.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :risen,
  mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
  mailgun_key: System.get_env("MAILGUN_API_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

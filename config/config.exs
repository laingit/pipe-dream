# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :pipe_dream,
  ecto_repos: [PipeDream.Repo]

# Configures the endpoint
config :pipe_dream, PipeDream.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5mR5kzK0xWsEWy7gM0xGaeU0Zy9YJGXy1RjN65zYlrjZu0T3otLvn5529SWWX4wi",
  render_errors: [view: PipeDream.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PipeDream.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

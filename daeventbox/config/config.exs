# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :daeventbox,
  ecto_repos: [Daeventbox.Repo]

# Configures the endpoint
config :daeventbox, DaeventboxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3wI4+EWY/crKcN/Ab5oi/5s8RN6iqL4xaU9uuMxx7u1wnCNqdZXcz7EdTd0Bu3BO",
  render_errors: [view: DaeventboxWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Daeventbox.PubSub,
           adapter: Phoenix.PubSub.PG2]


config :daeventbox, Daeventbox.Mailer,
   adapter: Bamboo.MailgunAdapter,
   api_key: "key-175430f23107dfb44ed8fe0bb7856095",
   domain: "mg.romariofitzgerald.com"

config :daeventbox, Daeventbox.Guardian,
      issuer: "Daeventbox",
      allowed_algos: ["ES512"],
      secret_key: %{
                  "crv" => "P-521",
                  "d" => "axDuTtGavPjnhlfnYAwkHa4qyfz2fdseppXEzmKpQyY0xd3bGpYLEF4ognDpRJm5IRaM31Id2NfEtDFw4iTbDSE",
                  "kty" => "EC",
                  "x" => "AL0H8OvP5NuboUoj8Pb3zpBcDyEJN907wMxrCy7H2062i3IRPF5NQ546jIJU3uQX5KN2QB_Cq6R_SUqyVZSNpIfC",
                  "y" => "ALdxLuo6oKLoQ-xLSkShv_TA0di97I9V92sg1MKFava5hKGST1EKiVQnZMrN3HO8LtLT78SNTgwJSQHAXIUaA-lV"
                }


config :arc,
   bucket: "sirfitz",
   virtual_host: true

config :ex_aws,
   access_key_id: "AKIAJBD4NDWEQ774NUNQ",
   secret_access_key: "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",
   region: "us-east-2",
   bucket: "sirfitz",
   host: "s3.us-east-2.amazonaws.com",
   s3: [
   scheme: "https://",
   host: "s3.us-east-2.amazonaws.com",
   region: "us-east-2"
   ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

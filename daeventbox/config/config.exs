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

config :ueberauth, Ueberauth,
  providers: [
    facebook: {Ueberauth.Strategy.Facebook, [default_scope: "email,public_profile,user_friends"]},
  ]

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: "1667764676590362",
  client_secret: "e3e6beccc350eb9215b84d31cc603c5f",
  redirect_uri: "http://1f937a7e.ngrok.io/auth/facebook/callback"

config :arc,
   bucket: "daeventboximages",
   virtual_host: true

config :ex_aws,
   access_key_id: "AKIAJKQU6CJTUAFUTBPA",
   secret_access_key: "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",
   region: "us-east-2",
   bucket: "daeventboximages",
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

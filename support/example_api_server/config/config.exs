use Mix.Config

config :example_api_server, ExampleApiServer,
  adapter: Plug.Cowboy,
  plug: ExampleApiServer.API,
  scheme: :http,
  port: 8880

config :example_api_server,
  maru_servers: [ExampleApiServer]

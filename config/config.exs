import Config

config :j1605,
  device: [
    address: "192.168.1.250",
    port: 2000
  ]

import_config "#{config_env()}.exs"

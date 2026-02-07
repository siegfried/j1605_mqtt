import Config

config :j1605,
  device: [
    address: "192.168.1.250",
    port: 2000
  ]

config :j1605_mqtt,
  host: System.get_env("J1605_MQTT_HOST") || "localhost"

import_config "#{config_env()}.exs"

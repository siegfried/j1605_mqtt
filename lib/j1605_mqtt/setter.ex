defmodule J1605Mqtt.Setter do
  use Tortoise.Handler

  require Logger

  def init(args) do
    {:ok, args}
  end

  def connection(status, state) do
    Logger.info("MQTT connection status: #{status}")
    {:ok, state}
  end

  # topic filter j1605/states/set/+
  def handle_message(["j1605", "states", "set", relay], payload, state) do
    id = String.to_integer(relay) - 1

    Logger.info("Received command: relay=#{relay}, id=#{id}, payload=#{payload}")

    if payload == "0" do
      J1605.turn_off(id)
    else
      J1605.turn_on(id)
    end

    Process.sleep(500)

    {:ok, state}
  end

  def handle_message(topic, _payload, state) do
    Logger.warn("Unknown topic: #{topic}")
    {:ok, state}
  end

  def subscription(_status, _topic_filter, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    # tortoise doesn't care about what you return from terminate/2,
    # that is in alignment with other behaviours that implement a
    # terminate-callback
    :ok
  end
end

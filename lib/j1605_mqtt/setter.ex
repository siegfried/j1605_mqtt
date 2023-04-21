defmodule J1605Mqtt.Setter do
  use Tortoise.Handler

  require Logger

  def init(args) do
    {:ok, args}
  end

  def connection(_status, state) do
    # `status` will be either `:up` or `:down`; you can use this to
    # inform the rest of your system if the connection is currently
    # open or closed; tortoise should be busy reconnecting if you get
    # a `:down`
    {:ok, state}
  end

  # topic filter j1605/states/set/+
  def handle_message(["j1605", "states", "set", relay], payload, state) do
    id = String.to_integer(relay) - 1

    if payload == "0" do
      J1605.turn_off(id)
    else
      J1605.turn_on(id)
    end

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

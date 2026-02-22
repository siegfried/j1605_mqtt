defmodule J1605Mqtt.Getter do
  use GenServer

  require Logger

  def start_link(client_id) do
    GenServer.start_link(__MODULE__, client_id)
  end

  def init(client_id) do
    with {:ok, _} <- J1605.subscribe() do
      Logger.info("Subscribed to J1605 device")
      {:ok, client_id}
    else
      error -> 
        Logger.error("Failed to subscribe to J1605 device: #{inspect(error)}")
        {:stop, error}
    end
  end

  def handle_info({:states, relay_states}, client_id) do
    for relay <- 0..15 do
      message = elem(relay_states, relay) |> encode()
      topic = "j1605/states/get/#{relay + 1}"
      Tortoise.publish(client_id, topic, message)
    end

    {:noreply, client_id}
  end

  defp encode(state) do
    case state do
      true -> "1"
      false -> "0"
    end
  end
end

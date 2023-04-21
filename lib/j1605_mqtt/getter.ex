defmodule J1605Mqtt.Getter do
  use GenServer

  def start_link(client_id) do
    GenServer.start_link(__MODULE__, client_id)
  end

  def init(client_id) do
    with {:ok, _} <- J1605.subscribe() do
      {:ok, client_id}
    else
      error -> {:stop, error}
    end
  end

  def handle_info({:states, relay_states}, client_id) do
    for relay <- 0..15 do
      topic = "j1605/states/get/#{relay}"
      message = elem(relay_states, relay) |> encode()
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

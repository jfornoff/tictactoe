defmodule TictactoeWeb.GameChannel do
  use TictactoeWeb, :channel

  alias Tictactoe.GameServer

  def join("game:" <> game_id, payload, socket) do
    game_id
    |> String.to_atom()
    |> find_or_start_game()
    |> GameServer.add_player()
    |> case do
      {:ok, player_identifier} -> {:ok, assign(socket, :tictactoe_sign, player_identifier)}
      {:error, error} -> {:error, error}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp find_or_start_game(game_id) do
    GameServer.start_link(game_id)
    |> case do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end

defmodule TictactoeWeb.GameChannel do
  use TictactoeWeb, :channel

  alias Tictactoe.GameServer

  def join("game:" <> game_id, _payload, socket) do
    game_id
    |> find_or_start_game()
    |> GameServer.add_player()
    |> case do
      {:ok, player_identifier} -> {:ok, assign(socket, :tictactoe_sign, player_identifier)}
      {:error, error} -> {:error, error}
    end
  end

  def handle_in("play", %{"x" => x, "y" => y}, %{topic: "game:" <> game_id} = socket) do
    game_pid = find_or_start_game(game_id)

    response =
      with :ok <- GameServer.play(game_pid, player_sign(socket), [x, y]) do
        :ok
      else
        {:error, error_identifier} -> {:error, %{description: error_message(error_identifier)}}
      end

    {:reply, response, socket}
  end

  defp player_sign(socket) do
    socket.assigns[:tictactoe_sign]
  end

  defp find_or_start_game(game_id) do
    game_id
    |> String.to_atom()
    |> GameServer.start_link()
    |> case do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp error_message(error_identifier) do
    case error_identifier do
      :game_not_full -> "Game not full yet!"
      :not_players_turn -> "Not your turn!"
      :invalid_position -> "Invalid field coordinate!"
      :field_used_already -> "Field used already!"
    end
  end
end

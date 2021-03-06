defmodule TictactoeWeb.GameChannel do
  use TictactoeWeb, :channel

  alias Tictactoe.{GameSupervisor, GameServer}
  alias TictactoeWeb.{Endpoint, PresenceTracker}
  alias TictactoeWeb.View.{BoardView, OutcomeView}

  def join("game:" <> game_id, _payload, socket) do
    game_id
    |> GameSupervisor.find_or_start_game()
    |> GameServer.add_player()
    |> case do
      {:ok, player_identifier} ->
        send(self(), {:after_join, game_id})

        {:ok, %{playing_as: player_identifier}, assign(socket, :playing_as, player_identifier)}

      {:error, error} ->
        {:error, error}
    end
  end

  def handle_in("play", %{"x" => x, "y" => y}, %{topic: "game:" <> game_id} = socket) do
    game_pid = GameSupervisor.find_or_start_game(game_id)

    response =
      with :ok <- GameServer.play(game_pid, player_sign(socket), [x, y]) do
        broadcast!(socket, "game_update", %{
          current_player: GameServer.playing_now(game_pid),
          board:
            game_pid
            |> GameServer.board()
            |> BoardView.encode_board()
        })

        :ok
      else
        {:end, outcome, board} ->
          broadcast!(socket, "game_end", %{
            outcome: OutcomeView.outcome_message(outcome),
            board: BoardView.encode_board(board)
          })

          :ok

        {:error, error_identifier} ->
          {:error, %{description: error_message(error_identifier)}}
      end

    {:reply, response, socket}
  end

  def handle_info({:after_join, game_id}, socket) do
    start_game_if_necessary(game_id, socket)
    track_player_presence(socket)

    {:noreply, socket}
  end

  def broadcast_left_player(game_topic) do
    Endpoint.broadcast(game_topic, "player_left", %{})
  end

  defp player_sign(socket), do: socket.assigns[:playing_as]

  defp start_game_if_necessary(game_id, socket) do
    game_pid = GameSupervisor.find_or_start_game(game_id)

    if GameServer.game_ready_to_start?(game_pid) do
      broadcast!(socket, "game_start", %{
        current_player: GameServer.playing_now(game_pid),
        board:
          game_pid
          |> GameServer.board()
          |> BoardView.encode_board()
      })
    end
  end

  defp track_player_presence(socket) do
    {:ok, _} = PresenceTracker.track_player(socket, player_sign(socket))
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

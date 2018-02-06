defmodule TictactoeWeb.GameChannel do
  use TictactoeWeb, :channel

  require Logger

  alias Tictactoe.GameServer
  alias Tictactoe.Game.State.JoinedPlayers
  alias TictactoeWeb.View.{BoardView, OutcomeView}

  def join("game:" <> game_id, _payload, socket) do
    game_id
    |> find_or_start_game()
    |> GameServer.add_player()
    |> case do
      {:ok, player_identifier} ->
        send(self(), {:after_join, game_id})

        {:ok, assign(socket, :tictactoe_sign, player_identifier)}

      {:error, error} ->
        {:error, error}
    end
  end

  def terminate(shutdown_tuple, %Phoenix.Socket{topic: "game" <> game_id}) do
    game_id
    |> find_or_start_game()
    |> GenServer.stop()

    Logger.info(inspect(game_id))

    shutdown_tuple
  end

  def handle_in("play", %{"x" => x, "y" => y}, %{topic: "game:" <> game_id} = socket) do
    game_pid = find_or_start_game(game_id)

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
    game_pid =
      game_id
      |> find_or_start_game()

    if GameServer.game_ready_to_start?(game_pid) do
      broadcast!(socket, "game_start", %{
        current_player: GameServer.playing_now(game_pid),
        board:
          game_pid
          |> GameServer.board()
          |> BoardView.encode_board()
      })
    end

    {:noreply, socket}
  end

  defp player_sign(socket), do: socket.assigns[:tictactoe_sign]

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

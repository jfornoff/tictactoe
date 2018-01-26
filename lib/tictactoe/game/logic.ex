defmodule Tictactoe.Game.Logic do
  alias Tictactoe.Game.State

  def play(%State{} = state, player, position) do
    with :ok <- State.JoinedPlayers.verify_complete(state.players),
         :ok <- verify_players_turn(state.playing_now, player),
         {:ok, new_board} <- State.Board.set_field(state.board, player, position) do
      new_state =
        state
        |> Map.put(:board, new_board)
        |> switch_playing_now()

      {:ok, new_state}
    end
  end

  defp verify_players_turn(playing, trying_to_play) when playing == trying_to_play, do: :ok
  defp verify_players_turn(_, _), do: {:error, :not_players_turn}

  defp switch_playing_now(state = %State{playing_now: "X"}), do: %State{state | playing_now: "O"}
  defp switch_playing_now(state = %State{playing_now: "O"}), do: %State{state | playing_now: "X"}
end

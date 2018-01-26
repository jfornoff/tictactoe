defmodule Tictactoe.Game.State do
  alias Tictactoe.Game.State.{Board, JoinedPlayers}
  defstruct players: JoinedPlayers.none(), board: Board.empty(), playing_now: "X"

  def initial, do: %__MODULE__{}

  def players(%__MODULE__{players: players}), do: players
  def board(%__MODULE__{board: board}), do: board

  def add_player(current = %__MODULE__{players: players}) do
    with {:ok, added_player, new_players} <- JoinedPlayers.add_player(players) do
      {:ok, added_player, %__MODULE__{current | players: new_players}}
    end
  end
end

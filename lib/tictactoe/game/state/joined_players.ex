defmodule Tictactoe.Game.State.JoinedPlayers do
  def none, do: :none

  def add_player(:none) do
    {:ok, "X", :x_joined}
  end

  def add_player(:x_joined) do
    {:ok, "O", :full}
  end

  def add_player(:full) do
    {:error, :game_full}
  end

  def verify_complete(:full), do: :ok
  def verify_complete(_), do: {:error, :game_not_full}
end

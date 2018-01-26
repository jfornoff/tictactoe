defmodule Tictactoe.GameServer do
  use GenServer
  alias Tictactoe.Game

  def start_link do
    GenServer.start_link(__MODULE__, Game.State.initial())
  end

  # Public API
  def add_player(game) do
    GenServer.call(game, :add_player)
  end

  def players(game) do
    GenServer.call(game, :get_players)
  end

  def board(game) do
    GenServer.call(game, :get_board)
  end

  def play(game, player, position) do
    GenServer.call(game, {:play, player, position})
  end

  # GenServer callbacks
  def handle_call(:add_player, _, state) do
    with {:ok, player_identifier, new_state} <- Game.State.add_player(state) do
      {:reply, {:ok, player_identifier}, new_state}
    else
      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:get_players, _, state) do
    {:reply, Game.State.players(state), state}
  end

  def handle_call(:get_board, _, state) do
    {:reply, Game.State.board(state), state}
  end

  def handle_call({:play, player, position}, _, state) do
    with {:ok, new_game_state} <- Game.Logic.play(state, player, position) do
      {:reply, :ok, new_game_state}
    else
      error ->
        {:reply, error, state}
    end
  end
end

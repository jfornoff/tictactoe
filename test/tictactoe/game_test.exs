defmodule Tictactoe.GameServerTest do
  use ExUnit.Case, async: true
  alias Tictactoe.GameServer

  setup :start_game_server

  describe ".add_player" do
    test "first assigns X", %{server: pid} do
      returned_value = GameServer.add_player(pid)

      assert(returned_value == {:ok, "X"})
    end

    test "then assigns O", %{server: pid} do
      GameServer.add_player(pid)
      returned_value = GameServer.add_player(pid)

      assert(returned_value == {:ok, "O"})
    end

    test "then errors", %{server: pid} do
      GameServer.add_player(pid)
      GameServer.add_player(pid)
      returned_value = GameServer.add_player(pid)

      assert(returned_value == {:error, :game_full})
    end
  end

  describe ".play with incomplete players" do
    test "errors when no two players", %{server: pid} do
      assert(GameServer.play(pid, "X", [1, 1]) == {:error, :game_not_full})
    end
  end

  describe ".play with all players joined (player ordering)" do
    setup :join_all_players

    test "it rejects the move if it's not the players turn", %{server: pid} do
      assert(GameServer.play(pid, "O", [1, 1]) == {:error, :not_players_turn})
    end

    test "the same player cannot play twice in a row", %{server: pid} do
      assert(:ok == GameServer.play(pid, "X", [1, 1]))
      assert({:error, :not_players_turn} == GameServer.play(pid, "X", [1, 2]))
    end
  end

  describe ".play with all players joined (board field collision)" do
    setup :join_all_players

    test "it does not allow using the same field twice", %{server: pid} do
      assert(:ok == GameServer.play(pid, "X", [1, 1]))
      assert({:error, :field_used_already} == GameServer.play(pid, "O", [1, 1]))
    end
  end

  defp start_game_server(_) do
    {:ok, pid} = GameServer.start_link()

    {:ok, server: pid}
  end

  defp join_all_players(%{server: pid}) do
    {:ok, "X"} = GameServer.add_player(pid)
    {:ok, "O"} = GameServer.add_player(pid)
    :ok
  end
end

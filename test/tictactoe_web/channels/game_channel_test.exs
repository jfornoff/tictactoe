defmodule TictactoeWeb.GameChannelTest do
  use TictactoeWeb.ChannelCase

  alias TictactoeWeb.GameChannel

  describe "a half-full Tictactoe game" do
    test "rejects play moves" do
      {:ok, _, first_player_socket} = join_player("first_player")

      ref = push(first_player_socket, "play", %{x: 1, y: 1})
      assert_reply(ref, :error, %{description: "Game not full yet!"})
    end
  end

  describe "a full Tictactoe game" do
    setup [:join_two_players]

    test "does not allow any more players to join" do
      assert({:error, :game_full} == join_player("third_player"))
    end

    test "it rejects the wrong player playing a move", %{
      second_player_socket: second_player_socket
    } do
      # O plays, is not allowed to
      ref = play_move(second_player_socket, 1, 1)
      assert_reply(ref, :error, %{description: "Not your turn!"})
    end

    test "it accepts the right player making a move", %{first_player_socket: first_player_socket} do
      ref = play_move(first_player_socket, 1, 1)
      assert_reply(ref, :ok)
    end
  end

  defp play_move(player_socket, x, y) do
    push(player_socket, "play", %{x: x, y: y})
  end

  defp join_player(player_name) do
    socket(player_name, %{}) |> subscribe_and_join(GameChannel, "game:foo")
  end

  defp join_two_players(context) do
    {:ok, _, first_player_socket} = join_player("first_player")
    {:ok, _, second_player_socket} = join_player("second_player")

    context
    |> Map.put(:first_player_socket, first_player_socket)
    |> Map.put(:second_player_socket, second_player_socket)
  end
end

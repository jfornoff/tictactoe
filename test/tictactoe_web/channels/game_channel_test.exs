defmodule TictactoeWeb.GameChannelTest do
  use TictactoeWeb.ChannelCase

  alias TictactoeWeb.GameChannel

  describe "a half-full Tictactoe game" do
    test "rejects play moves" do
      {:ok, _, x_socket} = join_player("x")

      ref = push(x_socket, "play", %{x: 1, y: 1})
      assert_reply(ref, :error, %{description: "Game not full yet!"})
    end
  end

  describe "the first player joining" do
    test "does not broadcasta a game_start event" do
      {:ok, _, _} = join_player("x")

      refute_broadcast("game_start", %{
        current_player: "X",
        board: %{top: ["", "", ""], middle: ["", "", ""], bottom: ["", "", ""]}
      })
    end
  end

  describe "the last player joining" do
    test "broadcasts a game_start event with all necessary information" do
      {:ok, _, _} = join_player("x")
      {:ok, _, _} = join_player("y")

      assert_broadcast("game_start", %{
        current_player: "X",
        board: %{top: ["", "", ""], middle: ["", "", ""], bottom: ["", "", ""]}
      })
    end
  end

  describe "a full Tictactoe game" do
    setup [:join_two_players]

    test "does not allow any more players to join" do
      assert({:error, :game_full} == join_player("third_player"))
    end

    test "it rejects the wrong player playing a move", %{
      o_socket: o_socket
    } do
      # O plays, is not allowed to
      ref = play_move(o_socket, 1, 1)
      assert_reply(ref, :error, %{description: "Not your turn!"})
    end

    test "it accepts the right player making a move", %{x_socket: x_socket} do
      ref = play_move(x_socket, 1, 1)
      assert_reply(ref, :ok)

      assert_broadcast("game_update", %{
        current_player: "O",
        board: %{top: ["", "", ""], middle: ["", "X", ""], bottom: ["", "", ""]}
      })
    end
  end

  defp play_move(player_socket, x, y) do
    push(player_socket, "play", %{x: x, y: y})
  end

  defp join_player(player_name) do
    socket(player_name, %{}) |> subscribe_and_join(GameChannel, "game:foo")
  end

  defp join_two_players(context) do
    {:ok, _, x_socket} = join_player("x")
    {:ok, _, o_socket} = join_player("o")

    context
    |> Map.put(:x_socket, x_socket)
    |> Map.put(:o_socket, o_socket)
  end
end

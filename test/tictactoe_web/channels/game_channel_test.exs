defmodule TictactoeWeb.GameChannelTest do
  use TictactoeWeb.ChannelCase

  alias TictactoeWeb.GameChannel

  test "allows two players to join at most" do
    {:ok, _, _} = socket("first_user", %{}) |> subscribe_and_join(GameChannel, "game:foo")

    {:ok, _, _} = socket("second_user", %{}) |> subscribe_and_join(GameChannel, "game:foo")

    {:error, :game_full} =
      socket("third_user", %{}) |> subscribe_and_join(GameChannel, "game:foo")
  end
end

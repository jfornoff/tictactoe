defmodule Tictactoe.GameTest do
  use ExUnit.Case, async: true
  alias Tictactoe.{Game, Board}

  describe ".init" do
    test "returns an new Game" do
      assert(Game.init() == %Game{players: [], board: Board.empty()})
    end
  end
end

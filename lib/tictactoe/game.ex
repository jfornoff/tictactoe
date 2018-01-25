defmodule Tictactoe.Game do
  alias Tictactoe.Board
  defstruct [:players, :board]

  def init do
    %__MODULE__{players: [], board: Board.empty()}
  end
end

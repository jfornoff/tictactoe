defmodule Tictactoe.Board do
  alias Tictactoe.BoardField

  defstruct fields: [
              [BoardField.empty(), BoardField.empty(), BoardField.empty()],
              [BoardField.empty(), BoardField.empty(), BoardField.empty()],
              [BoardField.empty(), BoardField.empty(), BoardField.empty()]
            ]

  def empty do
    %__MODULE__{}
  end
end

defmodule Tictactoe.Game.State.Board do
  alias Tictactoe.Game.State.BoardField

  defstruct fields: [
              [BoardField.empty(), BoardField.empty(), BoardField.empty()],
              [BoardField.empty(), BoardField.empty(), BoardField.empty()],
              [BoardField.empty(), BoardField.empty(), BoardField.empty()]
            ]

  def empty do
    %__MODULE__{}
  end

  def set_field(board = %__MODULE__{}, player, [x, y]) do
    with :ok <- verify_valid_position(x, y),
         :ok <- verify_field_unused(board, x, y) do
      new_board = %__MODULE__{fields: put_in(board.fields, [Access.at(x), Access.at(y)], player)}

      {:ok, new_board}
    end
  end

  defp verify_valid_position(x, y) do
    if x >= 0 && x <= 2 && y >= 0 && y <= 2 do
      :ok
    else
      {:error, :invalid_position}
    end
  end

  defp verify_field_unused(%__MODULE__{fields: fields}, x, y) do
    if get_in(fields, [Access.at(x), Access.at(y)]) == BoardField.empty() do
      :ok
    else
      {:error, :field_used_already}
    end
  end
end

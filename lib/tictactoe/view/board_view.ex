defmodule Tictactoe.View.BoardView do
  alias Tictactoe.Game.State.Board

  def encode_board(%Board{fields: [top_row, mid_row, bottom_row]}) do
    %{top: encode_row(top_row), middle: encode_row(mid_row), bottom: encode_row(bottom_row)}
  end

  defp encode_row(row) when is_list(row) and length(row) == 3 do
    Enum.map(row, &encode_field_state/1)
  end

  defp encode_field_state(field) do
    case field do
      :empty -> ""
      "X" -> "X"
      "O" -> "O"
      unknown -> raise "Trying to encode unknown field: #{inspect(unknown)}"
    end
  end
end

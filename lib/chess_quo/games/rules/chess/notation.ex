defmodule ChessQuo.Games.Rules.Chess.Notation do
  def index_to_algebraic(index) do
    file = rem(index, 8)
    rank = div(index, 8)

    "#{file_to_letter(file)}#{rank + 1}"
  end

  def algebraic_to_index(algebraic) do
    [file, rank] = String.to_charlist(algebraic)

    file_index = file - ?a
    rank_index = rank - 1

    rank_index * 8 + file_index
  end

  def index_to_hex_0x88(index) when is_integer(index) do
    file = rem(index, 8)
    rank = div(index, 8)
    rank * 16 + file
  end

  def hex_0x88_to_index(square) when is_integer(square) do
    # 0..7
    file = rem(square, 16)
    # 0..7
    rank = div(square, 16)
    # 0..63
    rank * 8 + file
  end

  defp file_to_letter(file) do
    <<?a + file>>
  end
end

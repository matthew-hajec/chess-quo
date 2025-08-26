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

  defp file_to_letter(file) do
    <<?a + file>>
  end
end

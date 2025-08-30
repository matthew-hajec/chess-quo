defmodule ChessQuo.Games.Rules.Chess.Notation do
  @moduledoc """
  Helpers for converting between different chess-square encodings.
  """

  @doc """
  Converts a 0–63 index into algebraic notation.

  ## Examples

      iex> ChessQuo.Games.Rules.Chess.Notation.index_to_algebraic(0)
      "a1"

      iex> ChessQuo.Games.Rules.Chess.Notation.index_to_algebraic(63)
      "h8"
  """
  def index_to_algebraic(index) do
    file = rem(index, 8)
    rank = div(index, 8)

    "#{file_to_letter(file)}#{rank + 1}"
  end

  @doc """
  Converts an algebraic notation string into a 0–63 index.

  ## Examples

      iex> ChessQuo.Games.Rules.Chess.Notation.algebraic_to_index("a1")
      0

      iex> ChessQuo.Games.Rules.Chess.Notation.algebraic_to_index("h8")
      63
  """
  def algebraic_to_index(algebraic) do
    <<file_char, rank_char>> = algebraic

    file_index = file_char - ?a
    rank_index = String.to_integer(<<rank_char>>) - 1

    rank_index * 8 + file_index
  end


  @doc """
  Converts a 0–63 index into 0x88 encoding.

  ## Examples

      iex> ChessQuo.Games.Rules.Chess.Notation.index_to_hex_0x88(0)
      0

      iex> ChessQuo.Games.Rules.Chess.Notation.index_to_hex_0x88(63)
      119
  """
  def index_to_hex_0x88(index) when is_integer(index) do
    file = rem(index, 8)
    rank = div(index, 8)
    rank * 16 + file
  end

  @doc """
  Converts a 0x88 encoded square back into a 0–63 index.

  ## Examples

      iex> ChessQuo.Games.Rules.Chess.Notation.hex_0x88_to_index(0)
      0

      iex> ChessQuo.Games.Rules.Chess.Notation.hex_0x88_to_index(119)
      63

      iex> i = 27
      iex> sq = ChessQuo.Games.Rules.Chess.Notation.index_to_hex_0x88(i)
      iex> ChessQuo.Games.Rules.Chess.Notation.hex_0x88_to_index(sq)
      27
  """
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

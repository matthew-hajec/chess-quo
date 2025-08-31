defmodule ChessQuo.Games.Rules.Chess.FENTest do
  use ExUnit.Case, async: true
  alias ChessQuo.Games.Rules.Chess.FEN

  describe "flip_side_clear_ep" do
    test "flips the side to move" do
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
      assert FEN.flip_side_clear_ep(fen) == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1"
    end

    test "clears the en passant target square" do
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq a8 0 1"
      assert FEN.flip_side_clear_ep(fen) == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1"
    end

    test "flips back the side to move and clears en passant target square" do
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq b4 0 1"
      flipped = FEN.flip_side_clear_ep(fen)
      assert FEN.flip_side_clear_ep(flipped) == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1"
    end
  end
end

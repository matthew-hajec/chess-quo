defmodule ChessQuo.Games.Rules.Chess.FENTest do
  use ChessQuo.DataCase, async: true
  import Mox
  alias ChessQuo.Games.Rules.Chess.FEN
  alias ChessQuo.Games

  # # SSetup mock stubs
  setup do
    ChessQuo.Games.MockTokens
    |> stub(:game_code, fn -> "DEFAULTCODE" end)
    |> stub(:secret, fn -> "DEFAULTSECRET" end)

    :ok
  end

  def parts(fen) do
    fen
    |> String.split(" ")
    |> List.to_tuple()
  end

  describe "flip_side_clear_ep/1" do
    test "flips the side to move" do
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

      assert FEN.flip_side_clear_ep(fen) ==
               "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1"
    end

    test "clears the en passant target square" do
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq a8 0 1"

      assert FEN.flip_side_clear_ep(fen) ==
               "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1"
    end

    test "flips back the side to move and clears en passant target square" do
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq b4 0 1"
      flipped = FEN.flip_side_clear_ep(fen)

      assert FEN.flip_side_clear_ep(flipped) ==
               "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1"
    end
  end

  describe "game_to_fen/1" do
    test "initializes FEN correctly" do
      {:ok, game} = Games.create_game("chess", "white")
      assert FEN.game_to_fen(game) == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    end
  end

  describe "game_to_fen/1 - piece placement" do
    test "empty board" do
      {:ok, game} = Games.create_game("chess", "white")
      game = %{game | board: []}

      assert FEN.game_to_fen(game) == "8/8/8/8/8/8/8/8 w KQkq - 0 1"
    end

    test "full board" do
      {:ok, game} = Games.create_game("chess", "white")

      game = %{
        game
        | board:
            Enum.map(0..63, fn pos ->
              %{"type" => "pawn", "color" => "white", "position" => pos}
            end)
      }

      assert FEN.game_to_fen(game) ==
               "PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP w KQkq - 0 1"
    end

    test "gaps in piece placement" do
      {:ok, game} = Games.create_game("chess", "white")

      test_board = [
        %{"type" => "rook", "color" => "black", "position" => 0},
        %{"type" => "bishop", "color" => "white", "position" => 1},
        %{"type" => "king", "color" => "white", "position" => 4},
        %{"type" => "pawn", "color" => "black", "position" => 37}
      ]

      game = %{
        game
        | board: test_board
      }

      assert FEN.game_to_fen(game) ==
               "8/8/8/5p2/8/8/8/rB2K3 w KQkq - 0 1"
    end
  end
end

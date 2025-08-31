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

  def fen_parts(fen) do
    split = String.split(fen, " ")

    %{
      "placement" => split |> List.first(),
      "turn" => split |> Enum.at(1),
      "castling" => split |> Enum.at(2),
      "en_passant" => split |> Enum.at(3),
      "halfmove" => split |> Enum.at(4),
      "fullmove" => split |> Enum.at(5)
    }
  end

  def castling_rights_meta(wks, wqs, bks, bqs) do
    %{
      "castling" => %{
        "white" => %{"kingside" => wks, "queenside" => wqs},
        "black" => %{"kingside" => bks, "queenside" => bqs}
      },
      "en-passant" => nil,
      "half-move-clock" => 0
    }
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

  describe "game_to_fen/1 - side to move string" do
    test "white to move" do
      {:ok, game} = Games.create_game("chess", "white")
      assert FEN.game_to_fen(game) =~ ~r/ w /
    end

    test "black to move" do
      {:ok, game} = Games.create_game("chess", "white")
      game = %{game | turn: "black"}
      assert FEN.game_to_fen(game) =~ ~r/ b /
    end
  end

  describe "game_to_fen/1 - castling string" do
    test "initial castling rights" do
      {:ok, game} = Games.create_game("chess", "white")
      parts = fen_parts(FEN.game_to_fen(game))
      assert parts["castling"] == "KQkq"
    end

    test "loses white kingside castling rights" do
      {:ok, game} = Games.create_game("chess", "white")
      # Loses kingside castling rights
      game = %{game | meta: castling_rights_meta(false, true, true, true)}
      parts = fen_parts(FEN.game_to_fen(game))
      assert parts["castling"] == "Qkq"
    end

    test "loses white queenside castling rights" do
      {:ok, game} = Games.create_game("chess", "white")
      # Loses queenside castling rights
      game = %{game | meta: castling_rights_meta(true, false, true, true)}
      parts = fen_parts(FEN.game_to_fen(game))
      assert parts["castling"] == "Kkq"
    end

    test "loses black kingside castling rights" do
      {:ok, game} = Games.create_game("chess", "white")
      # Loses kingside castling rights
      game = %{game | meta: castling_rights_meta(true, true, false, true)}
      parts = fen_parts(FEN.game_to_fen(game))
      assert parts["castling"] == "KQq"
    end

    test "loses black queenside castling rights" do
      {:ok, game} = Games.create_game("chess", "white")
      # Loses queenside castling rights
      game = %{game | meta: castling_rights_meta(true, true, true, false)}
      parts = fen_parts(FEN.game_to_fen(game))
      assert parts["castling"] == "KQk"
    end


    test "loses all castling rights" do
      {:ok, game} = Games.create_game("chess", "white")
      # Loses all castling rights
      game = %{game | meta: castling_rights_meta(false, false, false, false)}
      parts = fen_parts(FEN.game_to_fen(game))
      assert parts["castling"] == "-"
    end
  end
end

defmodule ChessQuo.Games.Rules.Chess do
  @behaviour ChessQuo.Games.RulesBehaviour

  alias ChessQuo.Games.Game
  alias ChessQuo.Games.Rules.Chess.MoveFinder
  alias ChessQuo.Games.Embeds.{Piece, Move}

  @impl true
  @spec initial_board() :: [ChessQuo.Games.Embeds.Piece.t(), ...]
  def initial_board do
    [
      # White pieces (back rank a1–h1, indices 0–7)
      # a1
      %Piece{type: "rook", color: :white, position: 0},
      # b1
      %Piece{type: "knight", color: :white, position: 1},
      # c1
      %Piece{type: "bishop", color: :white, position: 2},
      # d1
      %Piece{type: "queen", color: :white, position: 3},
      # e1
      %Piece{type: "king", color: :white, position: 4},
      # f1
      %Piece{type: "bishop", color: :white, position: 5},
      # g1
      %Piece{type: "knight", color: :white, position: 6},
      # h1
      %Piece{type: "rook", color: :white, position: 7},

      # White pawns (a2–h2, indices 8–15)
      # a2
      %Piece{type: "pawn", color: :white, position: 8},
      # b2
      %Piece{type: "pawn", color: :white, position: 9},
      # c2
      %Piece{type: "pawn", color: :white, position: 10},
      # d2
      %Piece{type: "pawn", color: :white, position: 11},
      # e2
      %Piece{type: "pawn", color: :white, position: 12},
      # f2
      %Piece{type: "pawn", color: :white, position: 13},
      # g2
      %Piece{type: "pawn", color: :white, position: 14},
      # h2
      %Piece{type: "pawn", color: :white, position: 15},

      # Black pawns (a7–h7, indices 48–55)
      # a7
      %Piece{type: "pawn", color: :black, position: 48},
      # b7
      %Piece{type: "pawn", color: :black, position: 49},
      # c7
      %Piece{type: "pawn", color: :black, position: 50},
      # d7
      %Piece{type: "pawn", color: :black, position: 51},
      # e7
      %Piece{type: "pawn", color: :black, position: 52},
      # f7
      %Piece{type: "pawn", color: :black, position: 53},
      # g7
      %Piece{type: "pawn", color: :black, position: 54},
      # h7
      %Piece{type: "pawn", color: :black, position: 55},

      # Black pieces (back rank a8–h8, indices 56–63)
      # a8
      %Piece{type: "rook", color: :black, position: 56},
      # b8
      %Piece{type: "knight", color: :black, position: 57},
      # c8
      %Piece{type: "bishop", color: :black, position: 58},
      # d8
      %Piece{type: "queen", color: :black, position: 59},
      # e8
      %Piece{type: "king", color: :black, position: 60},
      # f8
      %Piece{type: "bishop", color: :black, position: 61},
      # g8
      %Piece{type: "knight", color: :black, position: 62},
      # h8
      %Piece{type: "rook", color: :black, position: 63}
    ]
  end

  @impl true
  def initial_meta do
    %{
      "fen" => "rnnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
      # Defines whether the castling is available for each player
      "castling" => %{
        "white" => %{"kingside" => true, "queenside" => true},
        "black" => %{"kingside" => true, "queenside" => true}
      },
      # Defines the en-passant target square index (0-63)
      "en-passant" => nil,
      # Defines the half-move clock (for fifty-move rule)
      "half-move-clock" => 0
    }
  end

  @impl true
  def valid_moves(game, color) do
    all_moves = MoveFinder.all_valid_moves(game) ++ MoveFinder.all_valid_next_moves(game)

    moves =
      Enum.filter(all_moves, fn move ->
        move.from.color == color
      end)

    Enum.map(moves, &Move.build!/1)
  end

  # Apply_move is incomplete, it only changes the turn and moves the piece, but doesn't handle captures or even validation.
  @impl true
  def apply_move(game, %Move{} = move) do
    # Change the turn
    game = update_turn(game)

    # Delete the piece at `from`, and update the piece at `to`
    game = update_board(game, move)

    # Update meta information (like en-passant target square)
    game = update_meta(game, move)

    {:ok, game}
  end

  defp update_turn(%Game{turn: :white} = game), do: %Game{game | turn: :black}
  defp update_turn(%Game{turn: :black} = game), do: %Game{game | turn: :white}

  defp update_board(game, move) do
    board = game.board

    # Delete the piece `from`
    board = List.delete(board, move.from)

    # Append the piece at `to`
    board = board ++ [move.to]

    %Game{
      game
      | board: board
    }
  end

  defp update_meta(game, move) do
    game
    |> update_en_passant(move)
  end

  defp update_en_passant(game, move) do
    is_pawn? = move.from.type == "pawn"

    on_start? =
      (move.from.color == :white and move.from.position in 8..15) or
        (move.from.color == :black and move.from.position in 48..55)

    double_step? = abs(move.to.position - move.from.position) == 16

    # If a pawn moves two squares forward, set the en-passant target square
    if is_pawn? and on_start? and double_step? do
      en_passant_target =
        if move.from.color == :white do
          move.from.position + 8
        else
          move.from.position - 8
        end

      put_in(game.meta["en-passant"], en_passant_target)
    else
      put_in(game.meta["en-passant"], nil)
    end
  end
end

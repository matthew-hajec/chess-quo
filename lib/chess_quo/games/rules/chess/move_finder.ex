defmodule ChessQuo.Games.Rules.Chess.MoveFinder do
  alias ChessQuo.Games.Rules.Chess.FEN
  alias ChessQuo.Games.Rules.Chess.Notation
  alias ChessLogic.Position

  @doc """
  Finds all valid moves for the given game state.

  Considers the current player to move, so will only return moves that can be made on the current turn.
  """
  def all_valid_moves(game) do
    # Convert the game into FEN to pass into chess_logic
    fen = FEN.game_to_fen(game)

    # Position as denoted by the chess_logic library
    cl_position = Position.from_fen(fen)

    # Valid moves as denoted by the chess_logic library
    cl_moves = Position.all_possible_moves(cl_position)

    Enum.map(cl_moves, &to_chess_quo_move/1)
  end

  def to_chess_quo_move(%ChessLogic.Move{
        from: %ChessLogic.Piece{type: from_type, color: from_color, square: from_sq},
        to: %ChessLogic.Piece{type: to_type, color: to_color, square: to_sq}
      }) do
    # Convert the move from chess_logic format to chess_quo format
    %{
      "from" => %{
        "type" => Atom.to_string(from_type),
        "color" => Atom.to_string(from_color),
        "position" => Notation.hex_0x88_to_index(from_sq)
      },
      "to" => %{
        "type" => Atom.to_string(to_type),
        "color" => Atom.to_string(to_color),
        "position" => Notation.hex_0x88_to_index(to_sq)
      }
    }
  end
end

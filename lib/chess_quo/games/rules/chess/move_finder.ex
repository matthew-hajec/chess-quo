defmodule ChessQuo.Games.Rules.Chess.MoveFinder do
  alias ChessQuo.Games.Rules.Chess.FEN
  alias ChessQuo.Games.Rules.Chess.Notation
  alias ChessLogic.Position
  alias ChessQuo.Games.Embeds.Move

  @doc """
  Finds all valid moves for the given game state.

  Considers the current player to move, so will only return moves that can be made on the current turn.
  """
  def all_valid_moves(game) do
    fen = game.meta["fen"]

    # Position as denoted by the chess_logic library
    cl_position = Position.from_fen(fen)

    # Valid moves as denoted by the chess_logic library
    cl_moves = Position.all_possible_moves(cl_position)

    Enum.map(cl_moves, &to_chess_quo_move/1)
  end

  @doc """
  Finds all valid moves for the next player to move.
  """
  def all_valid_next_moves(game) do
    fen = game.meta["fen"]
    new_fen = FEN.flip_side_clear_ep(fen)

    # Position as denoted by the chess_logic library
    cl_position = Position.from_fen(new_fen)

    # Valid moves as denoted by the chess_logic library
    cl_moves = Position.all_possible_moves(cl_position)

    Enum.map(cl_moves, &to_chess_quo_move/1)
  end

  def apply_move(game, %Move{} = move) do
    fen = game.meta["fen"]
    cl_position = Position.from_fen(fen)
    cl_moves = Position.all_possible_moves(cl_position)

    case find_cl_move(cl_moves, move) do
      nil ->
        {:error, :invalid_move}

      cl_move ->
        new_cl_position = cl_move.new_position

        new_fen = Position.to_fen(new_cl_position)
        status = Position.status(new_cl_position)

        game = FEN.update_game_from_fen(game, new_fen)

        game = update_game_state(game, status)

        IO.inspect(game.state, label: "game state after move")
        IO.inspect(game.winner, label: "game winner after move")

        {:ok, game}
    end
  end

  def find_cl_move(cl_moves, %Move{} = move) do
    type_from_atom = String.to_atom(move.from.type)
    type_to_atom = String.to_atom(move.to.type)

    Enum.find(cl_moves, fn cl_move ->
      cl_move.from.square == Notation.index_to_hex_0x88(move.from.position) and
        cl_move.to.square == Notation.index_to_hex_0x88(move.to.position) and
        cl_move.from.type == type_from_atom and
        cl_move.to.type == type_to_atom and
        cl_move.from.color == move.from.color and
        cl_move.to.color == move.to.color
    end)
  end


  defp update_game_state(game, :checkmate) do
    # The winner is the player who just moved (i.e., not the current turn)
    winner = if game.turn == :white, do: :black, else: :white
    %{game | state: :finished, winner: winner}
  end

  defp update_game_state(game, :in_progress) do
    %{game | state: :playing, winner: nil}
  end

  defp update_game_state(game, :draw) do
    %{game | state: :finished, winner: nil}
  end

  defp to_chess_quo_move(%ChessLogic.Move{
         from: %ChessLogic.Piece{type: from_type, color: from_color, square: from_sq},
         to: %ChessLogic.Piece{type: to_type, color: to_color, square: to_sq}
       }) do
    # Convert the move from chess_logic format to chess_quo format
    %{
      from: %{
        type: Atom.to_string(from_type),
        color: from_color,
        position: Notation.hex_0x88_to_index(from_sq)
      },
      to: %{
        type: Atom.to_string(to_type),
        color: to_color,
        position: Notation.hex_0x88_to_index(to_sq)
      }
    }
  end
end

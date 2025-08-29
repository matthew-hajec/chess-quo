defmodule ChessQuo.Games.Rules do
  @moduledoc """
  This module defines the rules for the chess game.

  ## String Keys
  All game data uses string keys (e.g., piece["type"]) not atom keys (piece.type).
  This is consistent with how Ecto serializes the data to/from the database.
  """

  alias ChessQuo.Games.Game

  @doc """
  Returns the initial board configuration for the game.
  """
  @callback initial_board() :: Game.board()

  @doc """
  Returns the initial metadata for the game.
  """
  @callback initial_meta() :: map()

  @doc """
  Returns a list of valid moves for the given game state and player color.

  If it is not the current player's turn, the valid moves should be returned as if it is.
  """
  @callback valid_moves(game :: Game, color :: String.t()) :: [Game.move()]

  @doc """
  The color of the current player to move.
  """
  @callback current_turn(game :: Game) :: String.t()

  @doc """
  Applies a move to the board and returns updated board and meta.

  Implementations can update the meta field for variant-specific data (e.g., castling rights, en passant, etc.)
  """
  @callback apply_move(board :: Game.board(), move :: Game.move(), meta :: map()) ::
              {Game.board(), map()}
end

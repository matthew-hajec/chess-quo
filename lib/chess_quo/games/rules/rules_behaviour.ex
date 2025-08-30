defmodule ChessQuo.Games.RulesBehaviour do
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
  Applies a move to the board and returns updated game.

  This function is responsible for updating the following fields:
  - turn
  - board
  - state
  - winner
  - meta

  Any field can be left as-is if the implementation does not need to change them.
  Changes to any other fields are ignored.
  """
  @callback apply_move(game :: Game, move :: Game.move()) ::
              {:ok, Game} | {:error, :invalid_move}
end

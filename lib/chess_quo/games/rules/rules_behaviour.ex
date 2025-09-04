defmodule ChessQuo.Games.RulesBehaviour do
  @moduledoc """
  This module defines the rules for the chess game.
  """

  alias ChessQuo.Games.Game
  alias ChessQuo.Games.Embeds.Move
  alias ChessQuo.Games.Embeds.Piece

  @doc """
  Returns the initial board configuration for the game.
  """
  @callback initial_board() :: [Piece.t()]

  @doc """
  Returns the initial metadata for the game.
  """
  @callback initial_meta() :: map()

  @doc """
  Returns a list of valid moves for the given game state and player color.

  If it is not the current player's turn, the valid moves should be returned as if it is.
  """
  @callback valid_moves(game :: Game.t(), color :: String.t()) :: [Move.t()]

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

  Should check if the move is invalid, if so, should return {:error, :invalid_move}.
  """
  @callback apply_move(game :: Game.t(), move :: Move.t()) ::
              {:ok, Game.t()} | {:error, :invalid_move}
end

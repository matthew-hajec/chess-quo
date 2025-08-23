defmodule ChessQuo.Games.Rules do
  @moduledoc """
  This module defines the rules for the chess game.

  ## String Keys
  All game data uses string keys (e.g., piece["type"]) not atom keys (piece.type).
  This is consistent with how Ecto serializes the data to/from the database.
  """

  alias ChessQuo.Games.Game


  @callback initial_board() :: Game.board()

  @callback valid_moves(board :: Game.board(), color: String.t()) :: [Game.move()]

  @callback valid_move?(board :: Game.board(), move :: Game.move()) :: boolean()

  @callback apply_move(board :: Game.board(), move :: Game.move()) :: Game.board()
end

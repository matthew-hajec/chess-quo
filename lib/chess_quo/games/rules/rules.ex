defmodule ChessQuo.Games.Rules do
  @moduledoc """
  This module defines the rules for the chess game.

  ## NOTE: All keys should be atoms (e.g., `piece.type`), not strings (e.g., `piece["type"]`). This is due to Ecto's serialization.
  """

  alias ChessQuo.Games.Game


  @callback initial_board() :: Game.board()

  @callback valid_moves(board :: Game.board(), color: String.t()) :: [Game.move()]

  @callback valid_move?(board :: Game.board(), move :: Game.move()) :: boolean()

  @callback apply_move(board :: Game.board(), move :: Game.move()) :: Game.board()
end

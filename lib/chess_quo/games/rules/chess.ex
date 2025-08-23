defmodule ChessQuo.Games.Rules.Chess do
  @behaviour ChessQuo.Games.Rules

  # Keys in the game data are strings, not atoms (see the documentation for `ChessQuo.Games.Game` for details)
  @dialyzer {:nowarn_function, [{:initial_board, 0}]}

  @impl true
  def initial_board do
    [
      # White pieces (back rank a1–h1, indices 0–7)
      %{"type" => "rook",   "color" => "white", "position" => 0},  # a1
      %{"type" => "knight", "color" => "white", "position" => 1},  # b1
      %{"type" => "bishop", "color" => "white", "position" => 2},  # c1
      %{"type" => "queen",  "color" => "white", "position" => 3},  # d1
      %{"type" => "king",   "color" => "white", "position" => 4},  # e1
      %{"type" => "bishop", "color" => "white", "position" => 5},  # f1
      %{"type" => "knight", "color" => "white", "position" => 6},  # g1
      %{"type" => "rook",   "color" => "white", "position" => 7},  # h1

      # White pawns (a2–h2, indices 8–15)
      %{"type" => "pawn", "color" => "white", "position" => 8},   # a2
      %{"type" => "pawn", "color" => "white", "position" => 9},   # b2
      %{"type" => "pawn", "color" => "white", "position" => 10},  # c2
      %{"type" => "pawn", "color" => "white", "position" => 11},  # d2
      %{"type" => "pawn", "color" => "white", "position" => 12},  # e2
      %{"type" => "pawn", "color" => "white", "position" => 13},  # f2
      %{"type" => "pawn", "color" => "white", "position" => 14},  # g2
      %{"type" => "pawn", "color" => "white", "position" => 15},  # h2

      # Black pawns (a7–h7, indices 48–55)
      %{"type" => "pawn", "color" => "black", "position" => 48},  # a7
      %{"type" => "pawn", "color" => "black", "position" => 49},  # b7
      %{"type" => "pawn", "color" => "black", "position" => 50},  # c7
      %{"type" => "pawn", "color" => "black", "position" => 51},  # d7
      %{"type" => "pawn", "color" => "black", "position" => 52},  # e7
      %{"type" => "pawn", "color" => "black", "position" => 53},  # f7
      %{"type" => "pawn", "color" => "black", "position" => 54},  # g7
      %{"type" => "pawn", "color" => "black", "position" => 55},  # h7

      # Black pieces (back rank a8–h8, indices 56–63)
      %{"type" => "rook",   "color" => "black", "position" => 56}, # a8
      %{"type" => "knight", "color" => "black", "position" => 57}, # b8
      %{"type" => "bishop", "color" => "black", "position" => 58}, # c8
      %{"type" => "queen",  "color" => "black", "position" => 59}, # d8
      %{"type" => "king",   "color" => "black", "position" => 60}, # e8
      %{"type" => "bishop", "color" => "black", "position" => 61}, # f8
      %{"type" => "knight", "color" => "black", "position" => 62}, # g8
      %{"type" => "rook",   "color" => "black", "position" => 63}  # h8
    ]
end


  @impl true
  def valid_moves(_board, _color) do
    []
  end

  @impl true
  def valid_move?(_board, _move) do
    false
  end

  @impl true
  def apply_move(board, _move) do
    board
  end
end

defmodule ChessQuo.Games.Rules.Chess do
  @behaviour ChessQuo.Games.Rules

  # Keys in the game data are strings, not atoms (see the documentation for `ChessQuo.Games.Game` for details)
  @dialyzer {:nowarn_function, [{:initial_board, 0}, {:valid_moves, 2}]}

  @impl true
  def initial_board do
    [
      # White pieces (back rank a1–h1, indices 0–7)
      # a1
      %{"type" => "rook", "color" => "white", "position" => 0},
      # b1
      %{"type" => "knight", "color" => "white", "position" => 1},
      # c1
      %{"type" => "bishop", "color" => "white", "position" => 2},
      # d1
      %{"type" => "queen", "color" => "white", "position" => 3},
      # e1
      %{"type" => "king", "color" => "white", "position" => 4},
      # f1
      %{"type" => "bishop", "color" => "white", "position" => 5},
      # g1
      %{"type" => "knight", "color" => "white", "position" => 6},
      # h1
      %{"type" => "rook", "color" => "white", "position" => 7},

      # White pawns (a2–h2, indices 8–15)
      # a2
      %{"type" => "pawn", "color" => "white", "position" => 8},
      # b2
      %{"type" => "pawn", "color" => "white", "position" => 9},
      # c2
      %{"type" => "pawn", "color" => "white", "position" => 10},
      # d2
      %{"type" => "pawn", "color" => "white", "position" => 11},
      # e2
      %{"type" => "pawn", "color" => "white", "position" => 12},
      # f2
      %{"type" => "pawn", "color" => "white", "position" => 13},
      # g2
      %{"type" => "pawn", "color" => "white", "position" => 14},
      # h2
      %{"type" => "pawn", "color" => "white", "position" => 15},

      # Black pawns (a7–h7, indices 48–55)
      # a7
      %{"type" => "pawn", "color" => "black", "position" => 48},
      # b7
      %{"type" => "pawn", "color" => "black", "position" => 49},
      # c7
      %{"type" => "pawn", "color" => "black", "position" => 50},
      # d7
      %{"type" => "pawn", "color" => "black", "position" => 51},
      # e7
      %{"type" => "pawn", "color" => "black", "position" => 52},
      # f7
      %{"type" => "pawn", "color" => "black", "position" => 53},
      # g7
      %{"type" => "pawn", "color" => "black", "position" => 54},
      # h7
      %{"type" => "pawn", "color" => "black", "position" => 55},

      # Black pieces (back rank a8–h8, indices 56–63)
      # a8
      %{"type" => "rook", "color" => "black", "position" => 56},
      # b8
      %{"type" => "knight", "color" => "black", "position" => 57},
      # c8
      %{"type" => "bishop", "color" => "black", "position" => 58},
      # d8
      %{"type" => "queen", "color" => "black", "position" => 59},
      # e8
      %{"type" => "king", "color" => "black", "position" => 60},
      # f8
      %{"type" => "bishop", "color" => "black", "position" => 61},
      # g8
      %{"type" => "knight", "color" => "black", "position" => 62},
      # h8
      %{"type" => "rook", "color" => "black", "position" => 63}
    ]
  end

  @impl true
  def valid_moves(_board, _color) do
    [
      %{
        "from" => %{"type" => "pawn", "color" => "white", "position" => 8},
        "to" => %{"type" => "pawn", "color" => "white", "position" => 16},
        "by" => "white"
      }
    ]
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

defmodule ChessQuo.Games.Rules.Chess.FEN do
  alias ChessQuo.Games.Rules.Chess.Notation

  # A fen: "<Piece Placement> <Side to move> <Castling rights> <En passant> <Halfmove clock> <Fullmove number>"
  def game_to_fen(game) do
    piece_placement_string(game) <>
      " " <>
      side_to_move_string(game) <>
      " " <>
      castling_string(game) <>
      " " <>
      en_passant_string(game) <>
      " " <>
      half_move_clock_string(game) <>
      " " <>
      full_move_clock_string(game)
  end

  @doc """
  Flips the side to move and clears the en passant target square in a FEN string.
  """
  def flip_side_clear_ep(fen) do
    case String.split(fen, " ", parts: 6) do
      [a, side, c, _ep, e, f] ->
        new_side = if side == "w", do: "b", else: "w"
        Enum.join([a, new_side, c, "-", e, f], " ")
    end
  end

  # Generate the piece placement part of the FEN string
  defp piece_placement_string(game) do
    board = game.board

    fen_board =
      Enum.reduce(board, List.duplicate(nil, 64), fn piece, acc ->
        symbol = piece_to_fen_symbol(piece)
        List.replace_at(acc, piece["position"], symbol)
      end)

    8..1//-1
    |> Enum.map(fn rank ->
      row =
        for file <- 0..7 do
          idx = (rank - 1) * 8 + file
          Enum.at(fen_board, idx)
        end

      compress_row(row)
    end)
    |> Enum.join("/")
  end

  # Generate the side to move part of the FEN string
  defp side_to_move_string(game) do
    if rem(length(game.moves), 2) == 0, do: "w", else: "b"
  end

  defp castling_string(game) do
    castling = game.meta["castling"]

    wks = if castling["white"]["kingside"], do: "K", else: ""
    wqs = if castling["white"]["queenside"], do: "Q", else: ""
    bks = if castling["black"]["kingside"], do: "k", else: ""
    bqs = if castling["black"]["queenside"], do: "q", else: ""

    rights_string = wks <> wqs <> bks <> bqs
    if rights_string == "", do: "-", else: rights_string
  end

  defp en_passant_string(game) do
    en_passant = game.meta["en-passant"]

    if en_passant do
      Notation.index_to_algebraic(en_passant)
    else
      "-"
    end
  end

  defp half_move_clock_string(game) do
    half_move_clock = game.meta["half-move-clock"]
    Integer.to_string(half_move_clock)
  end

  defp full_move_clock_string(game) do
    Integer.to_string(div(length(game.moves), 2) + 1)
  end

  # Turn a row like ["P", nil, nil, "P", nil, "P", nil, nil]
  # into "P2P1P2"
  defp compress_row(squares) do
    # Walk the row left-to-right.
    # acc = list of output chunks (strings) built so far
    # empties = running count of consecutive nils
    {acc, empties} =
      Enum.reduce(squares, {[], 0}, fn
        # Case 1: Empty square -> just bump the empties counter
        nil, {acc, e} ->
          {acc, e + 1}

        # Case 2: Piece with no empties pending -> add the piece
        piece, {acc, 0} ->
          {[piece | acc], 0}

        # Case 3: Piece with empties pending -> flush the count first,
        # then add the piece, reset empties to 0
        piece, {acc, e} ->
          {[piece, Integer.to_string(e) | acc], 0}
      end)

    # After the loop, if there are still empties, flush them
    acc =
      if empties > 0 do
        [Integer.to_string(empties) | acc]
      else
        acc
      end

    # acc has been built in reverse order, so fix it and join into a string
    acc
    |> Enum.reverse()
    |> Enum.join()
  end

  defp piece_to_fen_symbol(piece) do
    map = %{
      "pawn" => "p",
      "rook" => "r",
      "knight" => "n",
      "bishop" => "b",
      "queen" => "q",
      "king" => "k"
    }

    symbol = Map.get(map, piece["type"])

    if piece["color"] == "white" do
      String.upcase(symbol)
    else
      symbol
    end
  end
end

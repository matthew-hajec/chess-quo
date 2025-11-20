defmodule ChessQuo.Games.Rules.Chess.FEN do
  alias ChessQuo.Games.Game
  alias ChessQuo.Games.Embeds.Piece

  def breakdown_fen(fen) do
    case String.split(fen, " ", parts: 6) do
      [piece_placement, side_to_move, castling, en_passant, half_move_clock, full_move_number] ->
        %{
          piece_placement: piece_placement,
          side_to_move: side_to_move,
          castling: castling,
          en_passant: en_passant,
          half_move_clock: String.to_integer(half_move_clock),
          full_move_number: String.to_integer(full_move_number)
        }
    end
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

  @doc """
  Updates a Game struct to reflect the given FEN string.
  """
  def update_game_from_fen(game = %Game{}, fen) do
    breakdown = breakdown_fen(fen)

    %Game{
      game
      | meta: Map.put(game.meta, "fen", fen),
        turn: to_turn(breakdown.side_to_move),
        board: to_board(breakdown.piece_placement)
    }
  end

  @doc """
  Parses only the FEN piece placement field (first field) into the board list of %Piece{}.

  Returns a flat list of pieces using internal indexing: a1=0..h1=7, a8=56..h8=63.
  """
  def parse_piece_placement(piece_placement), do: to_board(piece_placement)

  defp to_turn("w"), do: :white
  defp to_turn("b"), do: :black

  defp to_board(piece_placement) do
    # FEN lists ranks from 8 down to 1, files from 'a' to 'h'
    ranks = String.split(piece_placement, "/", trim: true)

    # Validate we have exactly 8 ranks
    if length(ranks) != 8 do
      raise ArgumentError, "invalid FEN piece placement: expected 8 ranks, got #{length(ranks)}"
    end

    {pieces, final_rank, final_file} =
      Enum.reduce(ranks, {[], 8, 0}, fn rank_str, {acc, rank, _file} ->
        {rank_pieces, file_after} = parse_rank(rank_str, rank)
        {acc ++ rank_pieces, rank - 1, file_after}
      end)

    # After processing 8 ranks, we should be at rank 0 and file reset to 8 from the last processed rank
    if final_rank != 0 do
      raise ArgumentError, "invalid FEN piece placement: processed rank ended at #{final_rank}"
    end

    if final_file != 8 do
      # Each rank must total 8 squares
      raise ArgumentError, "invalid FEN piece placement: a rank did not sum to 8 squares"
    end

    pieces
  end

  defp parse_rank(rank_str, rank_num) do
    # Iterate characters, build pieces for this rank; return {pieces, file_after}
    {pieces, file} =
      rank_str
      |> String.graphemes()
      |> Enum.reduce({[], 0}, fn ch, {acc, file} ->
        cond do
          ch =~ ~r/^[1-8]$/ ->
            {acc, file + String.to_integer(ch)}

          ch in ["P", "N", "B", "R", "Q", "K", "p", "n", "b", "r", "q", "k"] ->
            {color, type} = piece_from_fen_char(ch)
            # Internal index mapping: a1=0..h1=7, a8=56..h8=63
            index = file + (rank_num - 1) * 8
            piece = %Piece{type: type, color: color, position: index}
            {[piece | acc], file + 1}

          true ->
            raise ArgumentError, "invalid FEN character in rank: #{inspect(ch)}"
        end
      end)

    if file != 8 do
      raise ArgumentError, "invalid FEN rank: does not sum to 8 squares"
    end

    {Enum.reverse(pieces), file}
  end

  defp piece_from_fen_char(<<c::utf8>>) when c in ?A..?Z do
    {:white, piece_type(c)}
  end

  defp piece_from_fen_char(<<c::utf8>>) when c in ?a..?z do
    {:black, piece_type(c)}
  end

  defp piece_type(?P), do: "pawn"
  defp piece_type(?N), do: "knight"
  defp piece_type(?B), do: "bishop"
  defp piece_type(?R), do: "rook"
  defp piece_type(?Q), do: "queen"
  defp piece_type(?K), do: "king"
  defp piece_type(?p), do: "pawn"
  defp piece_type(?n), do: "knight"
  defp piece_type(?b), do: "bishop"
  defp piece_type(?r), do: "rook"
  defp piece_type(?q), do: "queen"
  defp piece_type(?k), do: "king"
end

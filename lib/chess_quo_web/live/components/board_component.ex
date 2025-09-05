defmodule ChessQuoWeb.BoardComponent do
  # Refactored to pure function components; state & events handled in GameLive
  use Phoenix.Component
  alias ChessQuo.Games.Embeds.Move
  alias ChessQuoWeb.GameComponents

  attr :game, :any, required: true
  attr :perspective, :atom, required: true
  attr :selected_square, :integer, default: nil
  attr :valid_moves, :list, default: []

  def board(assigns) do
    ~H"""
    <div class="w-full mx-auto select-none">
      <div class="grid grid-cols-8 gap-0 aspect-square w-full border-2 border-gray-800">
        <% rank_range = if @perspective == :white, do: 1..8, else: 8..1//-1 %>
        <% file_range = if @perspective == :white, do: ?a..?h, else: ?h..?a//-1 %>

        <%= for rank <- rank_range do %>
          <%= for file <- file_range do %>
            <% index = file - ?a + (8 - rank) * 8 %>
            <% light? = rem(file - ?a + rank, 2) == 1 %>
            <% piece = find_piece_at(index, @game.board) %>
            <% selected? = @selected_square == index %>
            <% selectable? = is_map(piece) and piece.color == @perspective %>
            <% valid_move = Enum.find(@valid_moves, fn move -> move.to.position == index end) %>

            <GameComponents.square
              ruleset="chess"
              index={index}
              light?={light?}
              piece={piece}
              selected?={selected?}
              selectable?={selectable?}
              move={if valid_move, do: Move.to_map(valid_move)}
            />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  defp find_piece_at(index, board_state) do
    Enum.find(board_state, fn piece -> piece.position == index end)
  end
end

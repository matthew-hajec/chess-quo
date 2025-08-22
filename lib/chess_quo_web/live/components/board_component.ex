defmodule ChessQuoWeb.BoardComponent do
  use ChessQuoWeb, :live_component

  @doc """
  Renders a generic extensible board component.

  Boarding indexing starts at a1=0, b1=1, and goes to h8=63.

  Piece rendering logic can be extended by modifying the `render_piece/3` function.

  ## Parameters
    * `perspective` - The perspective from which to render the board ("white" or "black").
    * `game_type` - The name of the game being played (e.g., "chess").
    * `board_state` - List of piece maps, each containing at least:
      - `type` - The type of the piece as an atom (e.g., "pawn", "rook", etc.).
      - `color` - The color of the piece ("white" or "black").
      - `position` - The index of the piece on the board (0-63).
  """

  def render(assigns) do
    # Index 0 = a1, index 1 = b1... index 8 = a2
    ~H"""
    <div class="w-full mx-auto">
      <div class="grid grid-cols-8 gap-0 aspect-square w-full border-2 border-gray-800">
        <% rank_range = if @perspective == "white" do 1..8 else 8..1//-1 end %>
        <% file_range = if @perspective == "white" do ?a..?h else ?h..?a//-1 end %>

        <%= for rank <- rank_range do %>
          <%= for file <- file_range do %>
            <% index = file - ?a + (8 - rank) * 8 %>
            <% is_light_square = rem(file - ?a + rank, 2) == 1 %>
            <% piece = find_piece_at(index, @board_state) %>
            <div
              class={[
                "aspect-square flex items-center justify-center text-xs sm:text-sm font-bold",
                if(is_light_square, do: "bg-amber-100", else: "bg-amber-700")
              ]}
              data-square-index={file - ?a + (8 - rank) * 8}
            >
              <%= if piece do %>
                <%= render_piece(@game_type, piece) %>
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  defp find_piece_at(index, board_state) do
    Enum.find(board_state, fn piece -> piece.position == index end)
  end

  defp render_piece("chess", piece) do
    piece_symbols = %{
      "pawn" => "♟",
      "rook" => "♖",
      "knight" => "♘",
      "bishop" => "♗",
      "queen" => "♕",
      "king" => "♔"
    }
    assigns = %{
      color_class: if(piece.color == "white", do: "text-white", else: "text-black"),
      symbol: piece_symbols[piece.type]
    }

    ~H"""
    <div class="w-full h-full flex items-center justify-center text-5xl">
      <span class={@color_class}><%= @symbol %></span>
    </div>
    """
  end
end

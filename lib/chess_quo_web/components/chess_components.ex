defmodule ChessQuoWeb.ChessComponents do
  use Phoenix.Component

  def chess_board(assigns) do
    ~H"""
    <div class="chess-board-container w-full mx-auto p-4">
      <div class="chess-board grid grid-cols-8 gap-0 aspect-square w-full border-2 border-gray-800">
        <%= for rank <- 8..1//-1 do %>
          <%= for file <- ?a..?h do %>
            <% square = <<file>> <> Integer.to_string(rank) %>
            <% is_light_square = rem(file - ?a + rank, 2) == 0 %>
            <div
              id={square}
              class={[
                "square aspect-square flex items-center justify-center text-xs sm:text-sm font-bold",
                if(is_light_square, do: "bg-amber-100", else: "bg-amber-700")
              ]}
              data-square={square}
              data-square-index={file - ?a + (8 - rank) * 8}
            >
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end

defmodule ChessQuoWeb.BoardComponent do
  use ChessQuoWeb, :live_component

  def render(assigns) do
    # Index 0 = a1, index 1 = b1... index 8 = a2
    ~H"""
    <div class="w-full mx-auto">
      <div class="grid grid-cols-8 gap-0 aspect-square w-full border-2 border-gray-800">
        <% rank_range = if @perspective == "white" do 1..8 else 8..1//-1 end %>
        <% file_range = if @perspective == "white" do ?a..?h else ?h..?a//-1 end %>

        <%= for rank <- rank_range do %>
          <%= for file <- file_range do %>
            <% is_light_square = rem(file - ?a + rank, 2) == 1 %>
            <div
              class={[
                "aspect-square flex items-center justify-center text-xs sm:text-sm font-bold",
                if(is_light_square, do: "bg-amber-100", else: "bg-amber-700")
              ]}
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

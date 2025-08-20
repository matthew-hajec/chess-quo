defmodule ChessQuoWeb.ChessLive.GameLive do
  use ChessQuoWeb, :live_view

  # def render(assigns) do
  #   ~H"""
  #   <div class="chess-board-container w-full mx-auto p-4">
  #     <div class="chess-board grid grid-cols-8 gap-0 aspect-square w-full border-2 border-gray-800">
  #       <%= for rank <- 8..1//-1 do %>
  #         <%= for file <- ?a..?h do %>
  #           <% square = <<file>> <> Integer.to_string(rank) %>
  #           <% is_light_square = rem(file - ?a + rank, 2) == 0 %>
  #           <div
  #             id={square}
  #             class={[
  #               "square aspect-square flex items-center justify-center text-xs sm:text-sm font-bold",
  #               if(is_light_square, do: "bg-amber-100", else: "bg-amber-700")
  #             ]}
  #             data-square={square}
  #             data-square-index={file - ?a + (8 - rank) * 8}
  #           >
  #           </div>
  #         <% end %>
  #       <% end %>
  #     </div>
  #   </div>
  #   """
  # end

  def mount(%{"code" => code}, _session, socket) do
    socket = assign(socket, :code, code)

    # Use the current URL to generate a link for the game
    link = ChessQuoWeb.Endpoint.url() <> ~p"/game/#{code}"
    socket = assign(socket, :game_link, link)

    {:ok, socket}
  end

  # Triggered when the user clicks the "Copy Join Link" button
  def handle_event("link_copied", _params, socket) do
    {:noreply, put_flash(socket, :info, "Game link copied to clipboard!")}
  end
end

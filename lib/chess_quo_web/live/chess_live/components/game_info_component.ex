defmodule ChessQuoWeb.GameInfoComponent do
  use ChessQuoWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-2xl">
      <div class="card-body">
        <h2 class="card-title">Game Info</h2>
        <div>
          <p>Join Code: <span id="join-code" class="font-mono"><%= @game.code %></span>
          <button
            class="cursor-pointer"
            id="copy-link-btn"
            aria-label="Copy game link"
            data-url={@game_link}
            phx-click="link_copied"
            phx-target={@myself}
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3" />
            </svg>
          </button>
          </p>
        </div>
        <p>You are: <%= String.capitalize(@player_color) %></p>
      </div>
    </div>
    """
  end

  def handle_event("link_copied", _params, socket) do
    # Handle the link copied event here
    # This would forward the event to the parent LiveView if needed
    send(self(), :link_was_copied)
    {:noreply, socket}
  end
end

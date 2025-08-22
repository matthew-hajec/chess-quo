defmodule ChessQuoWeb.ChessLive.GameLive do
  use ChessQuoWeb, :live_view

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

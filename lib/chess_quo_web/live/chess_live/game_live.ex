defmodule ChessQuoWeb.ChessLive.GameLive do
  use ChessQuoWeb, :live_view

  alias ChessQuo.Games

  def mount(%{"code" => code}, session, socket) do
    # Attempt to fetch the game by code
    case Games.get_game(code) do
      {:ok, game} ->
        player_color = session["player_color"]
        player_secret = session["player_secret"]

        case Games.validate_player(game, player_color, player_secret) do
          {:ok, _} ->
            link = ChessQuoWeb.Endpoint.url() <> ~p"/game/#{code}"

            # Assign the game to the socket
            {:ok,
              socket
              |> assign(:game, game)
              |> assign(:player_color, player_color)
              |> assign(:game_link, link)
            }
          {:error, :invalid_credentials} ->
            {:ok,
              socket
              |> put_flash(:error, "Invalid credentials.")
              |> redirect(to: ~p"/")}
        end
      {:error, :not_found} ->
        {:ok,
          socket
          |> put_flash(:error, "Game not found.")
          |> redirect(to: ~p"/")}
    end
  end

  # Triggered when the user clicks the "Copy Join Link" button
  def handle_event("link_copied", _params, socket) do
    {:noreply, put_flash(socket, :info, "Game link copied to clipboard!")}
  end
end

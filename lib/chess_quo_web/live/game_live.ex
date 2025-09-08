defmodule ChessQuoWeb.GameLive do
  use ChessQuoWeb, :live_view

  alias ChessQuo.Games

  def mount(%{"code" => code}, session, socket) do
    # Attempt to fetch the game by code
    case Games.get_game(code) do
      {:ok, game} ->
        player_color = session["player_color"]
        player_secret = session["player_secret"]

        case Games.validate_secret(game, player_color, player_secret) do
          {:ok, _} ->
            link = ChessQuoWeb.Endpoint.url() <> ~p"/play/#{code}"

            # Subscribe the player to the game updates
            Phoenix.PubSub.subscribe(ChessQuo.PubSub, "game:#{code}")

            # Assign the game to the socket
            {:ok,
             socket
             |> assign(:game, game)
             |> assign(:player_color, player_color)
             |> assign(:game_link, link)
             |> assign(:selected_square, nil)
             |> assign(:valid_moves, [])}

          {:error, :invalid_credentials} ->
            {:ok,
             socket
             |> redirect(to: ~p"/lobby/join/#{code}")}
        end

      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Game not found.")
         |> redirect(to: ~p"/")}
    end
  end

  # Receive broadcasts from either player and refresh assigns
  def handle_info({:game_updated, game}, socket) do
    {:noreply, assign(socket, :game, game)}
  end

  # Triggered when the user clicks the "Copy Join Link" button
  def handle_info(:link_was_copied, socket) do
    # Show a flash message indicating the link was copied
    {:noreply, put_flash(socket, :info, "Game link copied to clipboard!")}
  end

  # User selected a square
  def handle_event("select_square", %{"index" => index}, socket) do
    game = socket.assigns.game
    perspective = socket.assigns.player_color
    index = String.to_integer(to_string(index))

    piece = Enum.find(game.board, fn p -> p.position == index end)
    players_piece? = piece && piece.color == perspective

    cond do
      socket.assigns.selected_square == index ->
        {:noreply, deselect(socket)}

      players_piece? ->
        valid_moves = ChessQuo.Games.valid_moves_from_position(game, perspective, index)
        {:noreply, socket |> assign(:selected_square, index) |> assign(:valid_moves, valid_moves)}

      true ->
        {:noreply, deselect(socket)}
    end
  end

  def handle_event("make_move", %{"move" => move}, socket) do
    perspective = socket.assigns.player_color
    game = socket.assigns.game

    case ChessQuo.Games.apply_move(game, perspective, move) do
      {:ok, new_game} ->
        {:noreply, socket |> assign(:game, new_game) |> deselect()}

      {:error, :not_your_turn} ->
        {:noreply, deselect(socket)}
    end
  end

  def handle_event("initiate_promotion", %{"from_idx" => _from_idx, "to_idx" => _to_idx}, socket) do
    # Put flash
    {:noreply, put_flash(socket, :error, "Promotion not yet implemented.")}
  end

  def handle_event("resign", _, socket) do
    Games.resign(socket.assigns.game, socket.assigns.player_color)

    {:noreply, socket}
  end

  def handle_event("offer_draw", _, socket) do
    Games.request_draw(socket.assigns.game, socket.assigns.player_color)

    {:noreply, socket}
  end

  def handle_event("accept_draw", _, socket) do
    {:noreply, put_flash(socket, :error, "Draw acceptance not implemented.")}
  end

  def handle_event("decline_draw", _, socket) do
    {:noreply, put_flash(socket, :error, "Draw decline not implemented.")}
  end

  defp deselect(socket) do
    socket |> assign(:selected_square, nil) |> assign(:valid_moves, [])
  end
end

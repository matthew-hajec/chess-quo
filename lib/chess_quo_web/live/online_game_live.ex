defmodule ChessQuoWeb.OnlineGameLive do
  use ChessQuoWeb, :live_view

  alias ChessQuo.Games
  alias ChessQuo.Games.Embeds.{Move, Piece}
  alias ChessQuoWeb.GameLiveHTML

  def render(assigns) do
    GameLiveHTML.online(assigns)
  end

  def mount(%{"code" => code}, session, socket) do
    # On mount:
    # 1. Attempt to fetch the game by code
    # 2. Fetch player color and secret from session
    # 3. Validate the player's secret
    # 4. If valid, subscribe to game updates and assign game to socket

    # Attempt to fetch the game by code
    case Games.get_game(code) do
      {:ok, game} ->
        player_color = session["player_color"]
        player_secret = session["player_secret"]

        case Games.validate_secret(game, player_color, player_secret) do
          {:ok, _} ->
            link = ChessQuoWeb.Endpoint.url() <> ~p"/online/#{code}"

            # Subscribe the player to the game updates
            Phoenix.PubSub.subscribe(ChessQuo.PubSub, "game:#{code}")

            # Assign the game to the socket
            {:ok,
             socket
             |> assign(:game, game)
             |> assign(:player_color, player_color)
             |> assign(:game_link, link)
             |> assign(:selected_square, nil)
             |> assign(:valid_moves, [])
             |> assign(:promoting, nil)}

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
        # If game.is_singleplayer is true, change the player_color to the opposite color and the player_secret accordingly
        socket = if new_game.is_singleplayer do
          new_color = if perspective == :white, do: :black, else: :white
          new_secret = if new_color == :white, do: new_game.white_secret, else: new_game.black_secret
          socket
          |> assign(:player_color, new_color)
          |> assign(:player_secret, new_secret)
        else
          socket
        end

        {:noreply, socket |> assign(:game, new_game) |> deselect()}

      {:error, :not_your_turn} ->
        {:noreply, deselect(socket)}
    end
  end

  def handle_event("initiate_promotion", %{"from_idx" => from_idx, "to_idx" => to_idx}, socket) do
    {:noreply, assign(socket, :promoting, %{from_idx: from_idx, to_idx: to_idx})}
  end

  def handle_event(
        "complete_promotion",
        %{"piece-type" => piece_type, "from-idx" => from_idx, "to-idx" => to_idx},
        socket
      ) do
    move = %Move{
      from: %Piece{
        position: String.to_integer(from_idx),
        color: socket.assigns.player_color,
        type: "pawn"
      },
      to: %Piece{
        position: String.to_integer(to_idx),
        color: socket.assigns.player_color,
        type: piece_type
      },
      # Not used currently
      notation: "promotion buddy"
    }

    # Send to handle_event("make_move", ...)
    socket = assign(socket, :promoting, nil)
    handle_event("make_move", %{"move" => move}, socket)
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
    Games.respond_to_draw(socket.assigns.game, socket.assigns.player_color, true)

    {:noreply, socket}
  end

  def handle_event("decline_draw", _, socket) do
    Games.respond_to_draw(socket.assigns.game, socket.assigns.player_color, false)

    {:noreply, socket}
  end

  defp deselect(socket) do
    socket |> assign(:selected_square, nil) |> assign(:valid_moves, [])
  end
end

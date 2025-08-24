defmodule ChessQuoWeb.BoardComponent do
alias ChessQuoWeb.GameComponents
  use ChessQuoWeb, :live_component

  alias ChessQuo.Games
  alias ChessQuoWeb.GameComponents

  @doc """
  Renders a generic extensible board component.

  Boarding indexing starts at a1=0, b1=1, and goes to h8=63.

  Piece rendering logic can be extended by modifying the `render_piece/3` function.

  ## Parameters
    * `perspective` - The perspective from which to render the board ("white" or "black").
    * `game` - The game state, including the board and pieces.

  ## System Managed Parameters
    * `selected_square` - The currently selected square on the board, if any, otherwise `nil`.
    * `valid_moves` - The list of valid moves for the currently selected piece, if any, otherwise an empty list.
  """

  def render(assigns) do
    # Initialize system managed parameters
    assigns = assign_new(assigns, :selected_square, fn -> nil end)
    assigns = assign_new(assigns, :valid_moves, fn -> [] end)

    # Index 0 = a1, index 1 = b1... index 8 = a2
    ~H"""
    <div class="w-full mx-auto select-none">
      <div class="grid grid-cols-8 gap-0 aspect-square w-full border-2 border-gray-800">
        <% rank_range =
          if @perspective == "white" do
            1..8
          else
            8..1//-1
          end %>
        <% file_range =
          if @perspective == "white" do
            ?a..?h
          else
            ?h..?a//-1
          end %>

        <%= for rank <- rank_range do %>
          <%= for file <- file_range do %>
            <% index = file - ?a + (8 - rank) * 8 %>
            <% is_light_square = rem(file - ?a + rank, 2) == 1 %>
            <% piece = find_piece_at(index, @game.board) %>
            <% is_selected = @selected_square == index %>
            <% is_selectable = piece && piece["color"] == @perspective %>
            <% is_valid_move = Enum.any?(@valid_moves, fn move -> move["to"]["position"] == index end) %>

            <div
              class={[
                "aspect-square flex items-center justify-center text-xs sm:text-sm font-bold",
                if(is_light_square, do: "bg-amber-100", else: "bg-amber-700"),
                if(is_selected, do: "ring-4 ring-blue-400 ring-inset"),
                if(is_selectable, do: "cursor-pointer hover:opacity-80"),
                if(is_valid_move, do: "cursor-pointer bg-green-100")
              ]}
              data-square-index={file - ?a + (8 - rank) * 8}
              phx-click={if is_selectable, do: "select_square"}
              phx-value-index={index}
              phx-target={@myself}
            >
              <%= if piece do %>
                <GameComponents.icon piece={piece} ruleset={@game.ruleset} />
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("select_square", %{"index" => index}, socket) do
    # Convert the index to an integer
    index = String.to_integer(index)

    # If the square is already selected, deselect it
    new_selected = if socket.assigns[:selected_square] == index, do: nil, else: index

    # Only calculate valid moves if this is a selection and not a deselection
    valid_moves =
      if new_selected do
        Games.valid_moves_from_position(
          socket.assigns[:game],
          socket.assigns[:perspective],
          index
        )
      else
        []
      end

    {:noreply,
     socket
     |> assign(:selected_square, new_selected)
     |> assign(:valid_moves, valid_moves)}
  end

  defp find_piece_at(index, board_state) do
    Enum.find(board_state, fn piece -> piece["position"] == index end)
  end
end

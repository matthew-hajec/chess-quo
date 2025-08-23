defmodule ChessQuoWeb.BoardComponent do
  use ChessQuoWeb, :live_component

  @doc """
  Renders a generic extensible board component.

  Boarding indexing starts at a1=0, b1=1, and goes to h8=63.

  Piece rendering logic can be extended by modifying the `render_piece/3` function.

  ## Parameters
    * `perspective` - The perspective from which to render the board ("white" or "black").
    * `game_type` - The name of the game being played (e.g., "chess").
    * `board_state` - Board state of type `ChessQuo.Games.board()`
  """

  def render(assigns) do
    # Initialize the selected square as nil
    assigns = assign_new(assigns, :selected_square, fn -> nil end)

    # Index 0 = a1, index 1 = b1... index 8 = a2
    ~H"""
    <div class="w-full mx-auto">
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
            <% piece = find_piece_at(index, @board_state) %>
            <% is_selected = @selected_square == index %>
            <% is_selectable = piece && piece["color"] == @perspective %>

            <div
              class={[
                "aspect-square flex items-center justify-center text-xs sm:text-sm font-bold",
                if(is_light_square, do: "bg-amber-100", else: "bg-amber-700"),
                if(is_selected, do: "ring-4 ring-blue-400 ring-inset"),
                if(is_selectable, do: "cursor-pointer hover:opacity-80")
              ]}
              data-square-index={file - ?a + (8 - rank) * 8}
              phx-click={if is_selectable, do: "select_square"}
              phx-value-index={index}
              phx-target={@myself}
            >
              <%= if piece do %>
                {render_piece(@game_type, piece)}
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

    {:noreply, assign(socket, :selected_square, new_selected)}
  end

  defp find_piece_at(index, board_state) do
    Enum.find(board_state, fn piece -> piece["position"] == index end)
  end

  defp render_piece("chess", piece) do
    piece_svgs = %{
      "pawn" => %{
        "black" => "wikimedia/pawn-black.svg",
        "white" => "wikimedia/pawn-white.svg"
      },
      "rook" => %{
        "black" => "wikimedia/rook-black.svg",
        "white" => "wikimedia/rook-white.svg"
      },
      "knight" => %{
        "black" => "wikimedia/knight-black.svg",
        "white" => "wikimedia/knight-white.svg"
      },
      "bishop" => %{
        "black" => "wikimedia/bishop-black.svg",
        "white" => "wikimedia/bishop-white.svg"
      },
      "queen" => %{
        "black" => "wikimedia/queen-black.svg",
        "white" => "wikimedia/queen-white.svg"
      },
      "king" => %{
        "black" => "wikimedia/king-black.svg",
        "white" => "wikimedia/king-white.svg"
      }
    }

    assigns = %{
      svg_path: "/images/chess-pieces/" <> piece_svgs[piece["type"]][piece["color"]],
      piece_type: piece["type"],
      piece_color: piece["color"]
    }

    ~H"""
    <div class="w-full h-full flex items-center justify-center">
      <img src={@svg_path} alt={"#{@piece_color} #{@piece_type}"} class="w-3/4 h-3/4" />
    </div>
    """
  end
end

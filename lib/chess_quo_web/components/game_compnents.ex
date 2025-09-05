defmodule ChessQuoWeb.GameComponents do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :piece, :map
  attr :ruleset, :string

  def icon(%{ruleset: "chess"} = assigns) do
    piece_svgs = %{
      "pawn" => %{black: "wikimedia/pawn-black.svg", white: "wikimedia/pawn-white.svg"},
      "rook" => %{black: "wikimedia/rook-black.svg", white: "wikimedia/rook-white.svg"},
      "knight" => %{
        black: "wikimedia/knight-black.svg",
        white: "wikimedia/knight-white.svg"
      },
      "bishop" => %{
        black: "wikimedia/bishop-black.svg",
        white: "wikimedia/bishop-white.svg"
      },
      "queen" => %{black: "wikimedia/queen-black.svg", white: "wikimedia/queen-white.svg"},
      "king" => %{black: "wikimedia/king-black.svg", white: "wikimedia/king-white.svg"}
    }

    assigns =
      assigns
      |> Map.put(
        :svg_path,
        "/images/chess-pieces/" <> piece_svgs[assigns.piece.type][assigns.piece.color]
      )
      |> Map.put(:alt, "#{assigns.piece.color} #{assigns.piece.type}")

    ~H"""
    <img src={@svg_path} alt={@alt} class="w-3/4 h-3/4" draggable="false" />
    """
  end

  attr :ruleset, :string
  attr :index, :integer, required: true
  attr :light?, :boolean, required: true
  # Type `ChessQuo.Games.Game.piece()`
  attr :piece, :map, default: nil
  attr :selected?, :boolean, default: false
  attr :selectable?, :boolean, default: false
  attr :move, :any, default: nil

  def square(assigns) do
    assigns = Map.put_new(assigns, :valid_move?, assigns.move != nil)

    ~H"""
    <div
      class={[
        "aspect-square flex items-center justify-center text-xs sm:text-sm font-bold",
        if(@light?, do: "bg-amber-100", else: "bg-amber-700"),
        if(@selected?, do: "ring-4 ring-blue-400 ring-inset"),
        if(@valid_move?, do: "ring-4 ring-green-400 ring-inset"),
        if(@selectable? or @valid_move?, do: "cursor-pointer hover:opacity-80")
      ]}
      role="button"
      data-piece-color={if @piece, do: @piece.color, else: "none"}
      data-piece-type={if @piece, do: @piece.type, else: "none"}
      aria-pressed={to_string(@selected?)}
      phx-click={
        if @valid_move? do
          JS.push("make_move", value: %{move: @move})
        else
          JS.push("select_square", value: %{index: @index})
        end
      }
    >
      <%= if @piece do %>
        <ChessQuoWeb.GameComponents.icon piece={@piece} ruleset={@ruleset} />
      <% end %>
    </div>
    """
  end
end

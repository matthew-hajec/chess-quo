defmodule ChessQuoWeb.GameComponents do
  use Phoenix.Component

  attr :piece, :map
  attr :ruleset, :string

  def icon(%{ruleset: "chess"} = assigns) do
    piece_svgs = %{
      "pawn" => %{"black" => "wikimedia/pawn-black.svg", "white" => "wikimedia/pawn-white.svg"},
      "rook" => %{"black" => "wikimedia/rook-black.svg", "white" => "wikimedia/rook-white.svg"},
      "knight" => %{
        "black" => "wikimedia/knight-black.svg",
        "white" => "wikimedia/knight-white.svg"
      },
      "bishop" => %{
        "black" => "wikimedia/bishop-black.svg",
        "white" => "wikimedia/bishop-white.svg"
      },
      "queen" => %{"black" => "wikimedia/queen-black.svg", "white" => "wikimedia/queen-white.svg"},
      "king" => %{"black" => "wikimedia/king-black.svg", "white" => "wikimedia/king-white.svg"}
    }

    assigns =
      assigns
      |> Map.put(
        :svg_path,
        "/images/chess-pieces/" <> piece_svgs[assigns.piece["type"]][assigns.piece["color"]]
      )
      |> Map.put(:alt, "#{assigns.piece["color"]} #{assigns.piece["type"]}")

    ~H"""
    <img src={@svg_path} alt={@alt} class="w-3/4 h-3/4" />
    """
  end

  attr :ruleset, :string
  # Who receives events from this component
  attr :target, :any, required: true
  # The event to trigger on click
  attr :on_click, :string, required: true
  attr :index, :integer, required: true
  attr :light?, :boolean, required: true
  # Type `ChessQuo.Games.Game.piece()`
  attr :piece, :map, default: nil
  attr :selected?, :boolean, default: false
  attr :selectable?, :boolean, default: false
  attr :valid_move?, :boolean, default: false

  def square(assigns) do
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
      aria-pressed={to_string(@selected?)}
      phx-click={@on_click}
      phx-target={@target}
      phx-value-index={@index}
    >
      <%= if @piece do %>
        <ChessQuoWeb.GameComponents.icon piece={@piece} ruleset={@ruleset} />
      <% end %>
    </div>
    """
  end
end

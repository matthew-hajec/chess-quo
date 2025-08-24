defmodule ChessQuoWeb.Components.Piece do
  use Phoenix.Component

  attr :piece, :map
  attr :ruleset, :string

  def icon(%{ruleset: "chess"} = assigns) do
    piece_svgs = %{
      "pawn" => %{"black" => "wikimedia/pawn-black.svg",   "white" => "wikimedia/pawn-white.svg"},
      "rook" => %{"black" => "wikimedia/rook-black.svg",   "white" => "wikimedia/rook-white.svg"},
      "knight" => %{"black" => "wikimedia/knight-black.svg","white" => "wikimedia/knight-white.svg"},
      "bishop" => %{"black" => "wikimedia/bishop-black.svg","white" => "wikimedia/bishop-white.svg"},
      "queen" => %{"black" => "wikimedia/queen-black.svg", "white" => "wikimedia/queen-white.svg"},
      "king" => %{"black" => "wikimedia/king-black.svg",   "white" => "wikimedia/king-white.svg"}
    }

    assigns =
      assigns
      |> Map.put(:svg_path, "/images/chess-pieces/" <> piece_svgs[assigns.piece["type"]][assigns.piece["color"]])
      |> Map.put(:alt, "#{assigns.piece["color"]} #{assigns.piece["type"]}")

    ~H"""
    <img src={@svg_path} alt={@alt} class="w-3/4 h-3/4" />
    """
  end
end

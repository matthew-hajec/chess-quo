defmodule ChessQuoWeb.GameComponents do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  alias ChessQuo.Games.Embeds.Move

  attr :piece, :map
  attr :ruleset, :string

  def icon(%{ruleset: "chess"} = assigns) do
    ~H"""
    <img src={piece_src(@ruleset, @piece)} class="w-3/4 h-3/4" draggable="false" />
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
  attr :promotion_move?, :boolean, default: false

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
      data-index={@index}
      data-piece-color={if @piece, do: @piece.color, else: "none"}
      data-piece-type={if @piece, do: @piece.type, else: "none"}
      aria-pressed={to_string(@selected?)}
      phx-click={
        cond do
          @promotion_move? and @valid_move? ->
            JS.push("initiate_promotion",
              value: %{from_idx: @move.from.position, to_idx: @move.to.position}
            )

          @valid_move? ->
            JS.push("make_move", value: %{move: @move})

          true ->
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

  attr :game, :any, required: true
  attr :perspective, :atom, required: true
  attr :selected_square, :integer, default: nil
  attr :valid_moves, :list, default: []

  def board(assigns) do
    ~H"""
    <div class="relative w-full mx-auto select-none">
      <div class="grid grid-cols-8 gap-0 aspect-square w-full border-2 border-gray-800">
        <% rank_range = if @perspective == :white, do: 1..8, else: 8..1//-1 %>
        <% file_range = if @perspective == :white, do: ?a..?h, else: ?h..?a//-1 %>

        <%= for rank <- rank_range do %>
          <%= for file <- file_range do %>
            <% index = file - ?a + (8 - rank) * 8 %>
            <% light? = rem(file - ?a + rank, 2) == 1 %>
            <% piece = find_piece_at(index, @game.board) %>
            <% selected? = @selected_square == index %>
            <% selectable? = is_map(piece) and piece.color == @perspective %>
            <% valid_moves = Enum.filter(@valid_moves, fn move -> move.to.position == index end) %>

            <.square
              ruleset="chess"
              index={index}
              light?={light?}
              piece={piece}
              selected?={selected?}
              selectable?={selectable?}
              move={if valid_moves != [], do: Move.to_map(hd(valid_moves))}
              promotion_move?={length(valid_moves) > 1}
            />
          <% end %>
        <% end %>
      </div>

      <%= if @game.state == :waiting do %>
        <.board_overlay>
          <:title>Waiting for opponent...</:title>
          <:body>Send them the game link or have them enter the game code to join.</:body>
        </.board_overlay>
      <% end %>

      <%= if @game.state == :finished do %>
        <%= case @game.winner do %>
          <% :white -> %>
            <.board_overlay>
              <:title>White Wins!</:title>
              <:body>White has won the game.</:body>
            </.board_overlay>
          <% :black -> %>
            <.board_overlay>
              <:title>Black Wins!</:title>
              <:body>Black has won the game.</:body>
            </.board_overlay>
          <% nil -> %>
            <.board_overlay>
              <:title>It's a Draw!</:title>
              <:body>The game has ended in a draw.</:body>
            </.board_overlay>
        <% end %>
      <% end %>
    </div>
    """
  end

  slot :title
  slot :body

  defp board_overlay(assigns) do
    ~H"""
    <div class="absolute inset-0 flex items-center justify-center bg-gray-700/90">
      <div class="m-4 card bg-base-200 shadow-2xl">
        <div class="card-body">
          <h2 class="card-title flex items-center justify-center">{render_slot(@title)}</h2>
          <p>{render_slot(@body)}</p>
        </div>
      </div>
    </div>
    """
  end

  defp piece_src(ruleset, piece) do
    case ruleset do
      "chess" -> chess_piece_src(piece)
    end
  end

  defp chess_piece_src(piece) do
    "/images/chess-pieces/" <>
      case {piece.type, piece.color} do
        {"pawn", :white} -> "wikimedia/pawn-white.svg"
        {"rook", :white} -> "wikimedia/rook-white.svg"
        {"knight", :white} -> "wikimedia/knight-white.svg"
        {"bishop", :white} -> "wikimedia/bishop-white.svg"
        {"queen", :white} -> "wikimedia/queen-white.svg"
        {"king", :white} -> "wikimedia/king-white.svg"
        {"pawn", :black} -> "wikimedia/pawn-black.svg"
        {"rook", :black} -> "wikimedia/rook-black.svg"
        {"knight", :black} -> "wikimedia/knight-black.svg"
        {"bishop", :black} -> "wikimedia/bishop-black.svg"
        {"queen", :black} -> "wikimedia/queen-black.svg"
        {"king", :black} -> "wikimedia/king-black.svg"
      end
  end

  defp find_piece_at(index, board_state) do
    Enum.find(board_state, fn piece -> piece.position == index end)
  end
end

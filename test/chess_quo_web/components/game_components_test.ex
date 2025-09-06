defmodule ChessQuoWeb.GameComponentsTest do
  use ChessQuo.DataCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  alias Phoenix.LiveViewTest.DOM
  alias ChessQuo.Games

  setup do
    # Stub tokens so create_game generates deterministic values under test
    ChessQuo.Games.MockTokens
    |> stub(:game_code, fn -> "DEFAULTCODE" end)
    |> stub(:secret, fn -> "DEFAULTSECRET" end)

    # Create a real chess game with initial pieces
    {:ok, game} = Games.create_game("chess", "white")

    # Render the board from white's perspective
    html =
      render_component(&ChessQuoWeb.GameComponents.board/1,
        game: game,
        perspective: :white
      )

    {lazy, _tree} = DOM.parse_document(html)

    {:ok, lazy: lazy}
  end

  def classes_contain?(element, class) do
    classes = element |> DOM.attribute("class")
    String.contains?(classes, class)
  end

  describe "GameComponents.board/1" do
    test "an owned square has a hover class" do
      # Find a square that contains a white piece
      owned_square =
        lazy
        |> DOM.all("div[role='button'][data-piece-color='white']")
        |> Enum.at(0)

      refute is_nil(owned_square), "Expected to find at least one owned square for white"
      assert classes_contain?(owned_square, "hover:")
    end
  end
end

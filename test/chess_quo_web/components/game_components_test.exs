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

    :ok
  end

  def board_lazy(game, perspective, selected_square \\ nil, valid_moves \\ []) do
    html =
      render_component(&ChessQuoWeb.GameComponents.board/1,
        game: game,
        perspective: perspective,
        selected_square: selected_square,
        valid_moves: valid_moves
      )

    {lazy, _tree} = DOM.parse_document(html)
    lazy
  end

  def classes_contain?(element, class) do
    classes = element |> DOM.attribute("class")
    String.contains?(classes, class)
  end

  describe "GameComponents.board/1" do
    test "an owned square responds to mouse hover" do
      {:ok, game} = Games.create_game("chess", :white)

      lazy = board_lazy(game, :white)

      # Find a square that contains a white piece
      owned_square =
        lazy
        |> DOM.all("div[role='button'][data-piece-color='white']")
        |> Enum.at(0)

      refute is_nil(owned_square), "Expected to find at least one owned square for white"
      assert classes_contain?(owned_square, "hover:")
    end

    test "an unowned square does not respond to mouse hover" do
      {:ok, game} = Games.create_game("chess", :white)

      lazy = board_lazy(game, :black)

      # Find a square that contains a white piece
      owned_square =
        lazy
        |> DOM.all("div[role='button'][data-piece-color='none']")
        |> Enum.at(0)

      refute is_nil(owned_square), "Expected to find at least one owned square for white"

      refute classes_contain?(owned_square, "hover:"),
             "Unowned square should not include a hover:* class"
    end

    test "an opponent's piece square does not respond to mouse hover" do
      {:ok, game} = Games.create_game("chess", :white)

      lazy = board_lazy(game, :black)

      # Find a square that contains a white piece
      owned_square =
        lazy
        |> DOM.all("div[role='button'][data-piece-color='white']")
        |> Enum.at(0)

      refute is_nil(owned_square), "Expected to find at least one owned square for white"

      refute classes_contain?(owned_square, "hover:"),
             "Opponent's piece square should not include a hover:* class"
    end

    test "the style of a selected square is different than the style of an unselected square" do
      {:ok, game} = Games.create_game("chess", :white)

      lazy = board_lazy(game, :white, 8)

      selected_square =
        lazy
        |> DOM.all("div[role='button'][data-piece-color='white'][aria-pressed='true']")
        |> Enum.at(0)

      unselected_square =
        lazy
        |> DOM.all("div[role='button'][data-piece-color='white'][aria-pressed='false']")
        |> Enum.at(0)

      refute is_nil(selected_square), "Expected to find at least one selected square for white"

      refute is_nil(unselected_square),
             "Expected to find at least one unselected square for white"

      selected_classes = selected_square |> DOM.attribute("class")
      unselected_classes = unselected_square |> DOM.attribute("class")

      refute selected_classes == unselected_classes,
             "Selected and unselected squares should have different class lists"
    end

    test "the style of a valid move square is different than the style of an unselected square" do
      # The opponent needs to join so that the game is in play (moves are valid only when in play)
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # The white pawn at position 8 can move to position 16 at the start of the game
      valid_move =
        Enum.find(Games.valid_moves_from_position(game, :white, 8), fn m ->
          m.to.position == 16
        end)

      # Act
      lazy = board_lazy(game, :white, nil, [valid_move])

      # Assert
      valid_move_square =
        lazy
        |> DOM.all("div[data-index='16']")
        |> Enum.at(0)

      # Index 44 isn't our valid move square, so should be unselected
      unselected_square =
        lazy
        |> DOM.all("div[data-index='44']")
        |> Enum.at(0)

      refute is_nil(valid_move_square),
             "Expected to find at least one valid move square for white"

      refute is_nil(unselected_square),
             "Expected to find at least one unselected square for white"

      valid_move_classes = valid_move_square |> DOM.attribute("class")
      unselected_classes = unselected_square |> DOM.attribute("class")

      refute valid_move_classes == unselected_classes,
             "Valid move and unselected squares should have different class lists"
    end
  end
end

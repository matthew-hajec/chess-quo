defmodule ChessQuoWeb.GameLiveTest do
  use ChessQuoWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  alias ChessQuo.GamesFixtures
  alias ChessQuo.Games

  setup do
    game = GamesFixtures.game_fixture(%{ruleset: "chess"})

    # Mocks
    ChessQuo.Games.MockTokens
    |> stub(:game_code, fn -> "DEFAULTCODE" end)
    |> stub(:secret, fn -> "DEFAULTSECRET" end)

    {:ok, game: game}
  end

  test "renders game when given valid params", %{conn: conn, game: game} do
    conn =
      Plug.Test.init_test_session(conn, %{
        "player_color" => "white",
        "player_secret" => game.white_secret
      })

    assert {:ok, _lv, _html} = live(conn, ~p"/play/#{game.code}")
  end

  test "owned piece squares include a hover style class", %{conn: conn} do
    # Create a real chess game so the board has pieces
    assert {:ok, game} = Games.create_game("chess", "white")

    conn =
      Plug.Test.init_test_session(conn, %{
        "player_color" => "white",
        "player_secret" => game.white_secret
      })

    {:ok, lv, _html} = live(conn, ~p"/play/#{game.code}")

    assert has_element?(
             lv,
             "div[data-piece-color='white'][class*='hover:']"
           )
  end

  test "unowned piece squares do not include a hover style class", %{conn: conn} do
    # Create a real chess game so the board has pieces
    assert {:ok, game} = Games.create_game("chess", "white")

    conn =
      Plug.Test.init_test_session(conn, %{
        "player_color" => "white",
        "player_secret" => game.white_secret
      })

    {:ok, lv, _html} = live(conn, ~p"/play/#{game.code}")

    refute has_element?(
             lv,
             "div[data-piece-color='black'][class*='hover:']"
           )
  end

  test "unoccupied piece squares do not include a hover style class", %{conn: conn} do
    # Create a real chess game so the board has pieces
    assert {:ok, game} = Games.create_game("chess", "white")

    conn =
      Plug.Test.init_test_session(conn, %{
        "player_color" => "white",
        "player_secret" => game.white_secret
      })

    {:ok, lv, _html} = live(conn, ~p"/play/#{game.code}")

    refute has_element?(
             lv,
             "div[data-piece-color='none'][class*='hover:']"
           )
  end
end

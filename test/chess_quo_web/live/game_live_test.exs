defmodule ChessQuoWeb.GameLiveTest do
  use ChessQuoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias ChessQuo.GamesFixtures

  setup do
    game = GamesFixtures.game_fixture(%{ruleset: "chess"})
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
end

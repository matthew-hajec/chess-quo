defmodule ChessQuoWeb.OnlineGameLiveTest do
  use ChessQuoWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  alias ChessQuo.Games

  setup do
    ChessQuo.Games.MockTokens
    |> stub(:game_code, fn -> "DEFAULTCODE" end)
    |> stub(:secret, fn -> "DEFAULTSECRET" end)

    :ok
  end

  test "renders game when given valid params", %{conn: conn} do
    {:ok, game} = Games.create_game("chess", :white)

    conn =
      Plug.Test.init_test_session(conn, %{
        "player_color" => :white,
        "player_secret" => game.white_secret
      })

    assert {:ok, _lv, _html} = live(conn, ~p"/online/#{game.code}")
  end
end

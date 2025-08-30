defmodule ChessQuo.GamesTest do
  use ChessQuo.DataCase
  import Mox

  alias ChessQuo.GamesFixtures
  alias ChessQuo.Games.Game

  test "can insert and fetch a game" do
    game = GamesFixtures.game_fixture()
    assert game == Repo.get(Game, game.id)
  end

  test "create_game sets code and secrets from tokens module" do
    ChessQuo.Games.MockTokens
    |> expect(:game_code, fn -> "TESTCODE" end)
    |> expect(:secret, fn -> "SECRETONE" end)
    |> expect(:secret, fn -> "SECRETTWO" end)

    assert {:ok, game} = ChessQuo.Games.create_game("chess", "white")
    assert game.code == "TESTCODE"
    assert "SECRETONE" in [game.white_secret, game.black_secret]
    assert "SECRETTWO" in [game.white_secret, game.black_secret]
  end
end

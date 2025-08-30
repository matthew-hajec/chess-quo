defmodule ChessQuo.GamesTest do
  use ChessQuo.DataCase

  alias ChessQuo.GamesFixtures
  alias ChessQuo.Games.Game

  test "can insert and fetch a game" do
    game = GamesFixtures.game_fixture()
    assert game == Repo.get(Game, game.id)
  end
end

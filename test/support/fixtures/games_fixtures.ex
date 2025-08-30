defmodule ChessQuo.GamesFixtures do
  alias ChessQuo.Repo
  alias ChessQuo.Games.Game

  def game_fixture(attrs \\ %{}) do
    defaults = %{
      ruleset: "chess",
      code: "TEST12",
      password: "testpassword",
      white_secret: "white_secret",
      black_secret: "black_secret",
    }

    merged_attrs = Map.merge(defaults, attrs)
    {:ok, game} = Repo.insert(Game.system_changeset(%Game{}, merged_attrs))
    game
  end
end

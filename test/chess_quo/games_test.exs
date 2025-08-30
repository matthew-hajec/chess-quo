defmodule ChessQuo.GamesTest do
  use ChessQuo.DataCase
  import Mox

  alias ChessQuo.GamesFixtures
  alias ChessQuo.Games.Game

  setup :verify_on_exit!

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

  test "create_game raises when all attempts yield duplicate codes" do
    # Create a game with a duplicate code
    GamesFixtures.game_fixture(%{code: "COPY00"})

    ChessQuo.Games.MockTokens
    |> expect(:game_code, 3, fn -> "COPY00" end) # ATTEMPT ONE
    |> stub(:secret, fn -> "DEFAULTSECRET" end)

    # Should raise an error
    assert_raise RuntimeError, fn ->
      ChessQuo.Games.create_game("chess", "white", "", 3)
    end
  end

  test "create_game sets the host color as joined" do
    ChessQuo.Games.MockTokens
    |> expect(:game_code, fn -> "111111" end)
    |> expect(:game_code, fn -> "222222" end)
    |> stub(:secret, fn -> "DEFAULTSECRET" end)

    assert {:ok, game} = ChessQuo.Games.create_game("chess", "white")
    assert game.white_joined
    refute game.black_joined

    assert {:ok, game} = ChessQuo.Games.create_game("chess", "black")
    assert game.black_joined
    refute game.white_joined
  end
end

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

  test "create_game returns an error tuple when all attempts yield duplicate codes" do
    # Create a game with a duplicate code
    GamesFixtures.game_fixture(%{code: "COPY00"})

    ChessQuo.Games.MockTokens
    # ATTEMPT ONE
    |> expect(:game_code, 3, fn -> "COPY00" end)
    |> stub(:secret, fn -> "DEFAULTSECRET" end)

    # Should return an error tuple
    assert {:error, _changeset} = ChessQuo.Games.create_game("chess", "white", "", 3)
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

  test "create_game initializes the game using the provided ruleset" do
    mock_board = [%{"piece" => "pawn", "color" => "white", "position" => 1}]
    mock_meta = %{"initial" => "meta"}

    ChessQuo.Games.MockTokens
    |> expect(:game_code, fn -> "BOARD01" end)
    |> stub(:secret, fn -> "DEFAULTSECRET" end)

    ChessQuo.Games.Rules.MockRules
    |> expect(:initial_board, fn -> mock_board end)
    |> expect(:initial_meta, fn -> mock_meta end)

    assert {:ok, game} = ChessQuo.Games.create_game("mock", "white")
    assert game.board == mock_board
    assert game.meta == mock_meta
  end
end

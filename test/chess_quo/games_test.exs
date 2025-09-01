defmodule ChessQuo.GamesTest do
  use ChessQuo.DataCase, async: true
  import Mox

  alias ChessQuo.GamesFixtures
  alias ChessQuo.Games.Game
  alias ChessQuo.Games.Piece

  setup :verify_on_exit!

  # SSetup mock stubs
  setup do
    ChessQuo.Games.MockTokens
    |> stub(:game_code, fn -> "DEFAULTCODE" end)
    |> stub(:secret, fn -> "DEFAULTSECRET" end)

    ChessQuo.Games.Rules.MockRules
    |> stub(:initial_board, fn ->
      [%{type: "defaultpiece", color: :white, position: 1}]
    end)
    |> stub(:initial_meta, fn -> %{"initial" => "meta"} end)

    :ok
  end

  describe "create_game" do
    test "can insert and fetch a game" do
      game = GamesFixtures.game_fixture()
      assert game == Repo.get(Game, game.id)
    end

    test "create_game initializes in the waiting state" do
      assert {:ok, game} = ChessQuo.Games.create_game("mock", "white")
      assert game.state == "waiting"
    end

    test "create_game initializes white as the current turn" do
      assert {:ok, game} = ChessQuo.Games.create_game("mock", "white")
      assert game.turn == "white"
    end

    test "create_game initializes the winner as nil" do
      assert {:ok, game} = ChessQuo.Games.create_game("mock", "white")
      assert game.winner == nil
    end

    test "create_game initializes started at as nil" do
      assert {:ok, game} = ChessQuo.Games.create_game("mock", "white")
      assert game.started_at == nil
    end

    test "create_game sets code and secrets from tokens module" do
      ChessQuo.Games.MockTokens
      |> expect(:game_code, fn -> "TESTCODE" end)
      |> expect(:secret, fn -> "SECRETONE" end)
      |> expect(:secret, fn -> "SECRETTWO" end)

      assert {:ok, game} = ChessQuo.Games.create_game("mock", "white")
      assert game.code == "TESTCODE"
      assert "SECRETONE" in [game.white_secret, game.black_secret]
      assert "SECRETTWO" in [game.white_secret, game.black_secret]
    end

    test "create_game returns an error tuple when all attempts yield duplicate codes" do
      # Create a game with a duplicate code
      GamesFixtures.game_fixture(%{code: "COPY00"})

      ChessQuo.Games.MockTokens
      |> expect(:game_code, 3, fn -> "COPY00" end)

      # Should return an error tuple
      assert {:error, _changeset} = ChessQuo.Games.create_game("mock", "white", "", 3)
    end

    test "create_game sets the host color as joined" do
      ChessQuo.Games.MockTokens
      |> expect(:game_code, fn -> "111111" end)
      |> expect(:game_code, fn -> "222222" end)

      assert {:ok, game} = ChessQuo.Games.create_game("mock", "white")
      assert game.white_joined
      refute game.black_joined

      assert {:ok, game} = ChessQuo.Games.create_game("mock", "black")
      assert game.black_joined
      refute game.white_joined
    end

    test "create_game initializes the game using the provided ruleset" do
      mock_board = [%{type: "pawn", color: :white, position: 1}]
      mock_meta = %{"initial" => "meta"}

      ChessQuo.Games.Rules.MockRules
      |> expect(:initial_board, fn -> mock_board end)
      |> expect(:initial_meta, fn -> mock_meta end)

      assert {:ok, game} = ChessQuo.Games.create_game("mock", "white")
      assert game.board == [%Piece{type: "pawn", color: :white, position: 1}]
      assert game.meta == mock_meta
    end
  end
end

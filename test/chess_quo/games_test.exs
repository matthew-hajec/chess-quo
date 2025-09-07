defmodule ChessQuo.GamesTest do
  use ChessQuo.DataCase, async: true
  import Mox

  alias ChessQuo.Games
  alias ChessQuo.Games.Embeds.Piece

  setup :verify_on_exit!

  # Setup mock stubs
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

  describe "initializing games with create_game/2" do
    test "a new game can be created and retrieved" do
      {:ok, game} = ChessQuo.Games.create_game("mock", :white)
      assert {:ok, fetched_game} = ChessQuo.Games.get_game(game.code)
      assert fetched_game == game
    end

    test "games are initialized in the waiting state" do
      assert {:ok, game} = ChessQuo.Games.create_game("mock", :white)
      assert game.state == :waiting
    end

    test "white moves first" do
      assert {:ok, game} = ChessQuo.Games.create_game("mock", :white)
      assert game.turn == :white
    end

    test "games initialize without a winner" do
      assert {:ok, game} = ChessQuo.Games.create_game("mock", :white)
      assert game.winner == nil
    end

    test "the game does not immediately start" do
      assert {:ok, game} = ChessQuo.Games.create_game("mock", :white)
      assert game.started_at == nil
    end

    test "games generate codes and secrets using the Tokens module" do
      ChessQuo.Games.MockTokens
      |> expect(:game_code, fn -> "TESTCODE" end)
      |> expect(:secret, fn -> "SECRETONE" end)
      |> expect(:secret, fn -> "SECRETTWO" end)

      assert {:ok, game} = ChessQuo.Games.create_game("mock", :white)
      assert game.code == "TESTCODE"
      assert "SECRETONE" in [game.white_secret, game.black_secret]
      assert "SECRETTWO" in [game.white_secret, game.black_secret]
    end

    test "games handle duplicate codes by retrying" do
      ChessQuo.Games.MockTokens
      |> expect(:game_code, 4, fn -> "COPY00" end)

      {:ok, _game} = ChessQuo.Games.create_game("mock", :white)

      # Should return an error tuple
      assert {:error, _changeset} = ChessQuo.Games.create_game("mock", :white, "", 3)
    end

    test "games initialize with the host color as joined" do
      ChessQuo.Games.MockTokens
      |> expect(:game_code, fn -> "111111" end)
      |> expect(:game_code, fn -> "222222" end)

      assert {:ok, game} = ChessQuo.Games.create_game("mock", :white)
      assert game.white_joined
      refute game.black_joined

      assert {:ok, game} = ChessQuo.Games.create_game("mock", :black)
      assert game.black_joined
      refute game.white_joined
    end

    test "games initialize the board and metadata using the provided ruleset" do
      mock_board = [%{type: "pawn", color: :white, position: 1}]
      mock_meta = %{"initial" => "meta"}

      ChessQuo.Games.Rules.MockRules
      |> expect(:initial_board, fn -> mock_board end)
      |> expect(:initial_meta, fn -> mock_meta end)

      assert {:ok, game} = ChessQuo.Games.create_game("mock", :white)
      assert game.board == [%Piece{type: "pawn", color: :white, position: 1}]
      assert game.meta == mock_meta
    end
  end

  describe "fetching games with get_game!/1" do
    test "fetches the game if it exists" do
      {:ok, game} = Games.create_game("mock", :white)
      assert ChessQuo.Games.get_game!(game.code) == game
    end

    test "raises an error if the game does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        ChessQuo.Games.get_game!("nonexistent")
      end
    end
  end

  describe "fetching games with get_game/1" do
    test "fetches the game if it exists" do
      {:ok, game} = Games.create_game("mock", :white)
      assert {:ok, fetched_game} = ChessQuo.Games.get_game(game.code)
      assert fetched_game == game
    end

    test "returns an error if the game does not exist" do
      assert {:error, :not_found} = ChessQuo.Games.get_game("nonexistent")
    end
  end

  describe "joining a game with join_by_password/2" do
    test "a player can join a game with the correct password" do
      {:ok, game} = Games.create_game("mock", :white, "mypassword")
      assert {:ok, _color, _secret} = Games.join_by_password(game.code, "mypassword")
    end

    test "a player can not join a nonexistent game" do
      assert {:error, :not_found} = Games.join_by_password("NOEXIST", "mypassword")
    end

    test "a player can not join a game with an incorrect password" do
      {:ok, game} = Games.create_game("mock", :white, "mypassword")
      assert {:error, :invalid_password} = Games.join_by_password(game.code, "wrongpassword")
    end

    test "a player can not join a game that is already full" do
      {:ok, game} = Games.create_game("mock", :white)
      assert {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      assert {:error, :full} = Games.join_by_password(game.code, "")
    end
  end

  describe "validating player secrets with validate_secret/3" do
    test "validates correct secrets for white" do
      ChessQuo.Games.MockTokens
      |> expect(:secret, fn -> "SECRETONE" end)
      |> expect(:secret, fn -> "SECRETTWO" end)

      {:ok, game} = Games.create_game("mock", :white)
      assert {:ok, :white} = Games.validate_secret(game, :white, game.white_secret)
    end

    test "validates correct secrets for black" do
      ChessQuo.Games.MockTokens
      |> expect(:secret, fn -> "SECRETONE" end)
      |> expect(:secret, fn -> "SECRETTWO" end)

      {:ok, game} = Games.create_game("mock", :white)
      assert {:ok, :black} = Games.validate_secret(game, :black, game.black_secret)
    end

    test "rejects incorrect secrets" do
      ChessQuo.Games.MockTokens
      |> expect(:secret, fn -> "SECRETONE" end)
      |> expect(:secret, fn -> "SECRETTWO" end)

      {:ok, game} = Games.create_game("mock", :white)
      assert {:error, :invalid_credentials} = Games.validate_secret(game, :white, "wrong")
      assert {:error, :invalid_credentials} = Games.validate_secret(game, :black, "wrong")
    end

    test "black can not validate using white's secret" do
      ChessQuo.Games.MockTokens
      |> expect(:secret, fn -> "SECRETONE" end)
      |> expect(:secret, fn -> "SECRETTWO" end)

      {:ok, game} = Games.create_game("mock", :white)

      assert {:error, :invalid_credentials} =
               Games.validate_secret(game, :black, game.white_secret)
    end

    test "white can not validate using black's secret" do
      ChessQuo.Games.MockTokens
      |> expect(:secret, fn -> "SECRETONE" end)
      |> expect(:secret, fn -> "SECRETTWO" end)

      {:ok, game} = Games.create_game("mock", :white)

      assert {:error, :invalid_credentials} =
               Games.validate_secret(game, :white, game.black_secret)
    end
  end
end

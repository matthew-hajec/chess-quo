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

  describe "generating valid moves with valid_moves/2" do
    test "returns the correct number of valid moves for white in the chess starting position" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      moves = Games.valid_moves(game, :white)

      # 20 is the number of moves white can make from the starting position in chess
      assert length(moves) == 20
    end

    test "there are no valid moves if the game is waiting for the other player" do
      {:ok, game} = Games.create_game("chess", :white)
      moves = Games.valid_moves(game, :black)
      assert length(moves) == 0
    end
  end

  describe "generating valid moves from a position with valid_moves_from_position/3" do
    test "returns the correct moves for a piece in the chess starting position" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # The white knight at position 1 (b1) can move to positions 18 (a3) and 20 (c3)
      moves = Games.valid_moves_from_position(game, :white, 1)
      assert length(moves) == 2

      destinations = Enum.map(moves, fn move -> move.to.position end)
      assert Enum.sort(destinations) == [16, 18]
    end

    test "returns an empty list if there are no valid moves from that position" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # a1 has a blocked rook at the start of the game
      moves = Games.valid_moves_from_position(game, :white, 0)
      assert length(moves) == 0
    end

    test "returns an empty list if the piece at that position belongs to the opponent" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # Position 57 (b7) has a black pawn at the start of the game
      moves = Games.valid_moves_from_position(game, :white, 57)
      assert length(moves) == 0
    end

    test "returns an empty list if there is no piece at that position" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # Position 27 (d4) is empty at the start of the game
      moves = Games.valid_moves_from_position(game, :white, 27)
      assert length(moves) == 0
    end
  end

  describe "applying moves with apply_move/3" do
    test "a valid move is applied successfully" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # Move the knight from b1 (position 1) to c3 (position 18)
      move = %{
        from: %{type: "knight", color: :white, position: 1},
        to: %{type: "knight", color: :white, position: 18}
      }

      assert {:ok, updated_game} = Games.apply_move(game, :white, move)
      assert updated_game.turn == :black

      # Verify the knight has moved
      knight = Enum.find(updated_game.board, fn p -> p.type == "knight" and p.color == :white end)
      assert knight.position == 18
    end

    test "an invalid move is rejected" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # Attempt to move the knight from b1 (position 1) to b3 (position 17), which is invalid
      move = %{
        from: %{type: "knight", color: :white, position: 1},
        to: %{type: "knight", color: :white, position: 17}
      }

      assert {:error, :invalid_move} = Games.apply_move(game, :white, move)
    end

    test "a player cannot move when it's not their turn" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # Attempt to move black
      move = %{
        from: %{type: "knight", color: :black, position: 57},
        to: %{type: "knight", color: :black, position: 42}
      }

      assert {:error, :not_your_turn} = Games.apply_move(game, :black, move)
    end

    test "a player cannot move when the opponent has not joined yet" do
      {:ok, game} = Games.create_game("chess", :white)
      game = Games.get_game!(game.code)

      # Attempt to move white before black has joined
      move = %{
        from: %{type: "knight", color: :white, position: 1},
        to: %{type: "knight", color: :white, position: 18}
      }

      assert {:error, :invalid_move} = Games.apply_move(game, :white, move)
    end

    test "a player cannot move when the game is in the finished state" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # Manually set the game state to finished
      game = %{game | state: :finished}

      move = %{
        from: %{type: "knight", color: :white, position: 1},
        to: %{type: "knight", color: :white, position: 18}
      }

      assert {:error, :invalid_move} = Games.apply_move(game, :white, move)
    end
  end

  describe "resigning a game with resign/2" do
    test "a player can resign an ongoing game" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      assert {:ok, updated_game} = Games.resign(game, :white)
      assert updated_game.state == :finished
      assert updated_game.winner == :black
      assert updated_game.is_resignation == true
    end

    test "a player cannot resign a game that is already finished" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # Manually set the game state to finished
      game = %{game | state: :finished}

      assert {:error, :not_in_play} = Games.resign(game, :white)
    end

    test "a player cannot resign a game that is waiting for an opponent" do
      {:ok, game} = Games.create_game("chess", :white)
      game = Games.get_game!(game.code)

      assert {:error, :not_in_play} = Games.resign(game, :white)
    end
  end

  describe "requesting a draw with request_draw/2" do
    test "a player can request a draw in an ongoing game" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      assert {:ok, updated_game} = Games.request_draw(game, :white)
      assert updated_game.draw_requested_by == :white
    end

    test "a player cannot request a draw if the opponent has already requested one" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      {:ok, game} = Games.request_draw(game, :white)
      assert {:error, :draw_already_requested} = Games.request_draw(game, :black)
    end

    test "a player cannot request a draw in a finished game" do
      {:ok, game} = Games.create_game("chess", :white)
      {:ok, _color, _secret} = Games.join_by_password(game.code, "")
      game = Games.get_game!(game.code)

      # Manually set the game state to finished
      game = %{game | state: :finished}

      assert {:error, :not_in_play} = Games.request_draw(game, :white)
    end

    test "a player cannot request a draw in a waiting game" do
      {:ok, game} = Games.create_game("chess", :white)
      game = Games.get_game!(game.code)

      assert {:error, :not_in_play} = Games.request_draw(game, :white)
    end
  end
end

defmodule ChessQuo.Games.GameBuildToMapTest do
  use ExUnit.Case, async: true

  alias ChessQuo.Games.Game
  alias ChessQuo.Embeds.{Piece, Move}

  describe "build!/1" do
    test "accepts atom-keyed map and returns a Game struct" do
      attrs = %{ruleset: "mock", code: "CODE1", white_secret: "S1", black_secret: "S2"}
      game = Game.build!(attrs)

      assert %Game{} = game
      assert game.ruleset == "mock"
      assert game.code == "CODE1"
      assert game.white_secret == "S1"
      assert game.black_secret == "S2"
      # defaults from schema
      assert game.state == "waiting"
      assert game.turn == "white"
    end

    test "accepts string-keyed map and returns a Game struct" do
      attrs = %{"ruleset" => "mock", "code" => "CODE2", "white_secret" => "S1", "black_secret" => "S2", "password" => ""}
      game = Game.build!(attrs)

      assert %Game{} = game
      assert game.code == "CODE2"
      assert game.password == ""
    end

    test "accepts struct and returns it unchanged" do
      struct = %Game{ruleset: "mock", code: "CODE3", white_secret: "S1", black_secret: "S2"}
      assert Game.build!(struct) === struct
    end

    test "casts embeds when provided" do
      attrs = %{
        ruleset: "mock",
        code: "CODE4",
        white_secret: "S1",
        black_secret: "S2",
        board: [%{type: "pawn", color: :white, position: 1}],
        moves: [
          %{
            from: %{type: "pawn", color: :white, position: 1},
            to: %{type: "pawn", color: :white, position: 2}
          }
        ]
      }

      game = Game.build!(attrs)

      assert [%Piece{}] = game.board
      assert [%Move{}] = game.moves
    end
  end

  describe "to_map/1" do
    test "returns an atom-keyed map of primitive fields" do
      game = Game.build!(%{ruleset: "mock", code: "CODE5", white_secret: "S1", black_secret: "S2"})
      map = Game.to_map(game)

      assert is_map(map)
      assert Map.has_key?(map, :ruleset)
      assert map.ruleset == "mock"
      assert Map.has_key?(map, :lock_version)
      refute Map.has_key?(map, "ruleset")
    end

    test "serializes nested embeds to maps" do
      game =
        Game.build!(%{
          ruleset: "mock",
          code: "CODE6",
          white_secret: "S1",
          black_secret: "S2",
          board: [%{type: "rook", color: :black, position: 0}],
          moves: [
            %{
              from: %{type: "pawn", color: :white, position: 12},
              to: %{type: "pawn", color: :white, position: 20}
            }
          ]
        })

      map = Game.to_map(game)

      assert [%{type: "rook", color: :black, position: 0}] = map.board
      assert [
               %{
                 from: %{type: "pawn", color: :white, position: 12},
                 to: %{type: "pawn", color: :white, position: 20}
               }
             ] = map.moves
    end
  end
end

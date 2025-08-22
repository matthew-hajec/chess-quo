defmodule ChessQuo.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChessQuo.Games` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{})
      |> ChessQuo.Games.create_game()

    game
  end
end

defmodule ChessQuo.Games do
  @moduledoc """
  The Games context.
  """

  alias ChessQuo.Repo
  alias ChessQuo.Games.Game
  alias ChessQuo.Games.Tokens

  @doc """
  Creates a new game with a unique code and secrets for both players.

  Transparently retries up to `attempts` times if the only error is a unique constraint violation on the game code.
  """
  def create_game(attempts \\ 5) do
    attrs = %{
      code: Tokens.game_code(),
      white_secret: Tokens.secret(),
      black_secret: Tokens.secret(),
    }

    changeset = Game.system_changeset(%Game{}, attrs)

    case Repo.insert(changeset) do
      {:ok, game} ->
        {:ok, game}

      {:error, %Ecto.Changeset{errors: [code: {"has already been taken", _}]}} when attempts > 1 ->
        create_game(attempts - 1)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

end

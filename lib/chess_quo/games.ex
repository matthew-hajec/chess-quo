defmodule ChessQuo.Games do
  @moduledoc """
  The Games context.
  """

  alias ChessQuo.Repo
  alias ChessQuo.Games.Game
  alias ChessQuo.Games.Tokens

  # Map of rulesets to the implementation modules
  @ruleset_mods %{
    "chess" => ChessQuo.Games.Rules.Chess
  }

  @doc """
  Creates a new game with a unique code and secrets for both players.

  Transparently retries up to `attempts` times if the only error is a unique constraint violation on the game code.
  """
  def create_game(ruleset, password \\ "", attempts \\ 5) when is_map_key(@ruleset_mods, ruleset) do
    ruleset_impl = Map.get(@ruleset_mods, ruleset)

    attrs = %{
      ruleset: ruleset,
      code: Tokens.game_code(),
      password: password,
      white_secret: Tokens.secret(),
      black_secret: Tokens.secret(),
      board: ruleset_impl.initial_board(),
      meta: ruleset_impl.initial_meta()
    }

    changeset = Game.system_changeset(%Game{}, attrs)

    case Repo.insert(changeset) do
      {:ok, game} ->
        {:ok, game}

      {:error, %Ecto.Changeset{errors: [code: {"has already been taken", _}]}}
      when attempts > 1 ->
        create_game(ruleset, password, attempts - 1)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Retrieves a game by its code, raising an error if not found.
  """
  def get_game!(code) do
    Repo.get_by!(Game, code: code)
  end

  @doc """
  Gets a game by its code, returning {:ok, game} if found or {:error, :not_found} if not found.

  Raises an error if the database query fails.
  """
  def get_game(code) do
    case Repo.get_by(Game, code: code) do
      nil -> {:error, :not_found}
      game -> {:ok, game}
    end
  end

  @doc """
  Validates a player's credentials by checking the provided color and secret against the game's secrets.
  """
  def validate_player(game, player_color, player_secret) do
    case player_color do
      "white" when game.white_secret == player_secret -> {:ok, "white"}
      "black" when game.black_secret == player_secret -> {:ok, "black"}
      _ -> {:error, :invalid_credentials}
    end
  end

  def valid_moves(game, player_color) do
    ruleset_impl = Map.get(@ruleset_mods, game.ruleset)

    ruleset_impl.valid_moves(game, color: player_color)
  end

  def valid_moves_from_position(game, player_color, position) do
    valid_moves = valid_moves(game, player_color)
    Enum.filter(valid_moves, fn move -> move["from"]["position"] == position end)
  end
end

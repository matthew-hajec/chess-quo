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
  def create_game(ruleset, host_color, password \\ "", attempts \\ 5)
      when is_map_key(@ruleset_mods, ruleset) do
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

    # Add the joined property the attrs based on the host color
    attrs =
      if host_color == "white" do
        Map.put(attrs, :white_joined, true)
      else
        Map.put(attrs, :black_joined, true)
      end

    changeset = Game.system_changeset(%Game{}, attrs)

    case Repo.insert(changeset) do
      {:ok, game} ->
        {:ok, game}

      {:error, %Ecto.Changeset{errors: [code: {"has already been taken", _}]}}
      when attempts > 1 ->
        create_game(ruleset, host_color, password, attempts - 1)

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
  Allows a player to join a game by providing the game code and password.

  Returns {:error, :not_found} is the lobby isn't found.
  Returns {:error, :invalid_password} if the password is incorrect.
  Returns {:error, :full} if the lobby is full.
  Returns {:ok, color, secret} if the player successfully joins the game, where color is the player's color and secret is the player's secret.

  Raises an error if database queries fail.
  """
  def join_by_password(code, password) do
    # Returns {:error, :not_found} if not found
    with {:ok, game} <- get_game(code),
         # Returns {:error, :invalid_password} if the password is incorrect
         :ok <- validate_password(game, password) do
      # Returns {:error, :full} if the lobby is full, or {:ok, color, secret} if successful
      try_join(game)
    end
  end

  @doc """
  Validates a player's credentials by checking the provided color and secret against the game's secrets.
  """
  def validate_secret(game, player_color, player_secret) do
    case player_color do
      "white" when game.white_secret == player_secret -> {:ok, "white"}
      "black" when game.black_secret == player_secret -> {:ok, "black"}
      _ -> {:error, :invalid_credentials}
    end
  end

  @doc """
  Returns all valid moves for a player in a game.

  If it is not the current player's turn, the valid moves should be returned as if it is.
  """
  def valid_moves(game, player_color) do
    ruleset_impl = Map.get(@ruleset_mods, game.ruleset)

    ruleset_impl.valid_moves(game, player_color)
  end

  def valid_moves_from_position(game, player_color, position) do
    valid_moves = valid_moves(game, player_color)
    Enum.filter(valid_moves, fn move -> move["from"]["position"] == position end)
  end

  @doc """
  Validates and applies a move to the game state.

  Returns:
  - {:ok, game} if the move is valid and applied successfully
  - {:error, :not_your_turn} if it's not the player's turn.
  - {:error, :invalid_move} if the move is not valid for the current game state.
  """

  def apply_move(game, player_color, move) do

    ruleset_impl = Map.get(@ruleset_mods, game.ruleset)

    if game.turn != player_color do
      {:error, :not_your_turn}
    else
      with {:ok, new_game} <- ruleset_impl.apply_move(game, player_color, move) do
        attrs = %{
          turn: new_game.turn,
          board: new_game.board,
          state: new_game.state,
          winner: new_game.winner,
          meta: new_game.meta,
          moves: game.moves ++ [move]
        }

        Repo.update!(Game.system_changeset(game, attrs))
      end
    end
  end

  @doc """
  Check if a game code is possibly valid. (correct length and character set)
  """
  def possible_code(code) do
    Tokens.possible_code?(code)
  end

  defp validate_password(game, password) do
    if game.password == password do
      :ok
    else
      {:error, :invalid_password}
    end
  end

  # Returns {:ok, color, secret} if successful, or {:error, :full} if the game is full.
  # Raises an error if the database query fails.
  defp try_join(game) do
    case pick_slot(game) do
      {:ok, color} ->
        secret = if color == "white", do: game.white_secret, else: game.black_secret

        attrs = %{
          state: "playing",
          # Both players can be set to have joined, because the host joins the game when they create it
          white_joined: true,
          black_joined: true,
          started_at: DateTime.utc_now()
        }

        Repo.update!(Game.system_changeset(game, attrs))

        {:ok, color, secret}

      {:error, :full} = err ->
        err
    end
  end

  defp pick_slot(%{white_joined: true, black_joined: true}), do: {:error, :full}
  defp pick_slot(%{white_joined: true}), do: {:ok, "black"}
  defp pick_slot(%{black_joined: true}), do: {:ok, "white"}
end

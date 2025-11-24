defmodule ChessQuo.Games do
  @moduledoc """
  The Games context.
  """

  alias ChessQuo.Repo
  alias ChessQuo.Games.Game
  alias ChessQuo.Games.Embeds.Move

  # Map of rulesets to the implementation modules
  @ruleset_mods %{
    "chess" => ChessQuo.Games.Rules.Chess
  }

  # Fetch the ruleset modules from the application environment.
  # Uses the default @ruleset_mods if not set.
  # If the ruleset is not found, raises an error.
  defp ruleset_mod!(ruleset) do
    mods = Application.get_env(:chess_quo, :ruleset_mods, @ruleset_mods)
    rs = Map.get(mods, ruleset)

    if is_nil(rs) do
      raise ArgumentError, "Unknown ruleset: #{inspect(ruleset)}"
    end

    rs
  end

  # Fetch the tokens module from the application environment.
  # Uses the default ChessQuo.Games.Tokens if not set. (This is the implementation intended for production use.)
  defp tokens_mod, do: Application.get_env(:chess_quo, :tokens, ChessQuo.Games.Tokens)

  @doc """
  Creates and persists a new game in the database with a unique code and secrets for both players.

  ## Parameters
  - `ruleset`: The ruleset to use for the game (e.g., "chess").
  - `host_color`: The color chosen by the host player (:white or :black).
  - `is_local`: A boolean indicating if the game is singleplayer.
  - `password`: An optional password for the game (default is an empty string).
  - `attempts`: The number of attempts to create a game with a unique code (default is 5).

  ## Returns
  - `{:ok, game}`: If the game is created successfully.
  - `{:error, changeset}`: If the schema validation fails, or if a unique code could not be generated after the specified number of attempts.
  """
  def create_game(ruleset, host_color, password \\ "", is_local \\ false, attempts \\ 5) when is_atom(host_color) do
    ruleset_impl = ruleset_mod!(ruleset)

    attrs = %{
      is_local: is_local,
      ruleset: ruleset,
      code: tokens_mod().game_code(),
      password: password,
      white_secret: tokens_mod().secret(),
      black_secret: tokens_mod().secret(),
      meta: ruleset_impl.initial_meta()
    }

    # Add the joined property the attrs based on the host color
    attrs =
      if host_color == :white do
        Map.put(attrs, :white_joined, true)
      else
        Map.put(attrs, :black_joined, true)
      end

    # If singleplayer, set both players as joined AND immediately start the game
    attrs =
      if is_local do
        attrs
        |> Map.put(:white_joined, true)
        |> Map.put(:black_joined, true)
        |> Map.put(:state, :playing)
      else
        attrs
      end

    changeset =
      Game.changeset(%Game{}, attrs)
      |> Ecto.Changeset.put_embed(:board, ruleset_impl.initial_board())

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
  Attempts to get a game by its code from the database.

  ## Parameters
  - `code`: The unique code of the game.

  ## Returns
  - `%Game{}`: The game if found.

  ## Raises
  - `Ecto.NoResultsError`: If no game with the given code exists.
  """
  def get_game!(code) do
    Repo.get_by!(Game, code: code)
  end

  @doc """
  Attempts to get a game by its code from the database.

  ## Parameters
  - `code`: The unique code of the game.

  ## Returns
  - `{:ok, %Game{}}`: The game if found.
  - `{:error, :not_found}`: If no game with the given code exists.
  """
  def get_game(code) do
    case Repo.get_by(Game, code: code) do
      nil -> {:error, :not_found}
      game -> {:ok, game}
    end
  end

  @doc """
  Allows a player to join a game by providing the game code and password. Updates the game state in the database if successful.

  ## Parameters
  - `code`: The unique code of the game to join.
  - `password`: The password for the game.

  ## Returns
  - `{:ok, color, secret}`: If the player successfully joins the game, where `color` is the player's color (:white or :black) and `secret` is the player's secret.
  - `{:error, :not_found}`: If no game with the given code exists
  - `{:error, :invalid_password}`: If the provided password is incorrect.
  - `{:error, :full}`: If the game is already full (both players have joined).
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

  ## Parameters
  - `game`: The current game state.
  - `player_color`: The color of the player (:white or :black).
  - `player_secret`: The secret provided by the player.

  ## Returns
  - `{:ok, player_color}`: If the credentials are valid. The returned `player_color` is the same as the input.
  - `{:error, :invalid_credentials}`: If the credentials are invalid.
  """
  def validate_secret(%Game{} = game, player_color, player_secret)
      when is_atom(player_color) and is_binary(player_secret) do
    case player_color do
      :white when game.white_secret == player_secret -> {:ok, :white}
      :black when game.black_secret == player_secret -> {:ok, :black}
      _ -> {:error, :invalid_credentials}
    end
  end

  def validate_secret(_, _, _), do: {:error, :invalid_credentials}

  @doc """
  Returns all valid moves for a player in a game.

  If it is not the current player's turn, the valid moves are returned as if it is.

  ## Parameters
  - `game`: The current game state.
  - `player_color`: The color of the player requesting the valid moves. Can be :white or :black.

  ## Returns
  - `[]`: If the game is not in the :playing state.
  - `[%Move{}, ...]`: If the game is in the :playing state, a list of valid moves for the player.
  """
  def valid_moves(%Game{} = game, player_color) when is_atom(player_color) do
    game = Game.build!(game)

    if game.state != :playing do
      []
    else
      ruleset_impl = ruleset_mod!(game.ruleset)

      ruleset_impl.valid_moves(game, player_color)
    end
  end

  @doc """
  Returns all valid moves for a player from a specific position in a game.
  If it is not the current player's turn, the valid moves are returned as if it is.

  ## Parameters
  - `game`: The current game state.
  - `player_color`: The color of the player requesting the valid moves. Can be :white or :black.
  - `position`: The index of the position from which to get valid moves. (0..63)

  ## Returns
  - `[]`: If the game is not in the :playing state.
  - `[%Move{}, ...]`: If the game is in the :playing state, a list of valid moves for the player.
  """
  def valid_moves_from_position(%Game{} = game, player_color, position) do
    valid_moves = valid_moves(game, player_color)
    Enum.filter(valid_moves, fn move -> move.from.position == position end)
  end

  @doc """
  Attempts to apply a move to the game state. Updates the game state in the database if the move is valid.

  ## Parameters
  - `game`: The current game state.
  - `player_color`: The color of the player making the move (:white or :black).
  - `move`: The move to be applied. Can be a `%Move{}` struct or a map with the same fields.

  ## Returns
  - `{:ok, game}`: If the move is valid and applied successfully, where `game` is the updated game state.
  - `{:error, :not_your_turn}`: If it's not the player's turn
  - `{:error, :invalid_move}`: If the move is not valid for the current game state.
  """
  def apply_move(%Game{} = game, player_color, move) when is_atom(player_color) do
    move = Move.build!(move)

    ruleset_impl = ruleset_mod!(game.ruleset)

    cond do
      !game.black_joined or !game.white_joined or game.state != :playing ->
        {:error, :invalid_move}

      game.turn != player_color ->
        {:error, :not_your_turn}

      true ->
        with {:ok, new_game, move} <- ruleset_impl.apply_move(game, move) do
          game =
            game
            |> Game.changeset(%{
              turn: new_game.turn,
              state: new_game.state,
              winner: new_game.winner,
              meta: new_game.meta
            })
            |> Ecto.Changeset.put_embed(:board, new_game.board)
            |> Ecto.Changeset.put_embed(:moves, game.moves ++ [move])

          game = Repo.update!(game)

          # Broadcast the game update
          Phoenix.PubSub.broadcast(
            ChessQuo.PubSub,
            "game:#{game.code}",
            {:game_updated, game}
          )

          {:ok, game}
        end
    end
  end

  @doc """
  Resigns the specified player from the game. Updates the game state in the database.

  Returns an update Game struct where:
  - `state` is set to `:finished`
  - `winner` is set to the opposing player
  - `is_resignation` is set to `true`


  ## Parameters
  - `game`: The current game state.
  - `player_color`: The color of the player resigning (:white or :black).\

  ## Returns
  - `{:ok, game}`: If the resignation is successful, where `game` is the updated game state.
  - `{:error, :not_in_play}`: If the game state is not in-play.
  """
  def resign(%Game{} = game, player_color) when is_atom(player_color) do
    if game.state != :playing do
      {:error, :not_in_play}
    else
      winner = if player_color == :white, do: :black, else: :white

      attrs = %{
        state: :finished,
        winner: winner,
        is_resignation: true
      }

      game = Repo.update!(Game.changeset(game, attrs))

      # Broadcast the game update
      Phoenix.PubSub.broadcast(
        ChessQuo.PubSub,
        "game:#{game.code}",
        {:game_updated, game}
      )

      {:ok, game}
    end
  end

  @doc """
  Requests a draw from the specified player. Updates the game state in the database.

  Returns an updated Game struct where:
  - `draw_requested_by` is set to the requesting player (:white or :black)

  ## Parameters
  - `game`: The current game state.
  - `player_color`: The color of the player requesting the draw (:white or :black).

  ## Returns
  - `{:ok, game}`: If the draw request is successful, where `game` is the updated game state.
  - `{:error, :not_in_play}`: If the game state is not in-play.
  - `{:error, :draw_already_requested}`: If a draw has already been requested by either player.
  """
  def request_draw(%Game{} = game, player_color) when is_atom(player_color) do
    if game.state != :playing do
      {:error, :not_in_play}
    else
      if game.draw_requested_by != nil do
        {:error, :draw_already_requested}
      else
        attrs = %{
          draw_requested_by: player_color
        }

        game = Repo.update!(Game.changeset(game, attrs))

        # Broadcast the game update
        Phoenix.PubSub.broadcast(
          ChessQuo.PubSub,
          "game:#{game.code}",
          {:game_updated, game}
        )

        {:ok, game}
      end
    end
  end

  @doc """
  Responds to a draw request from the opposing player. Updates the game state in the database.

  If the draw is accepted, the game state is updated to:
  - `state` is set to `:finished`
  - `winner` is set to `nil`

  If the draw is declined, the game state is updated to:
  - `draw_requested_by` is set to `nil`

  ## Parameters
  - `game`: The current game state.
  - `player_color`: The color of the player responding to the draw request (:white or :black).
  - `accept`: A boolean indicating whether the draw is accepted (`true`) or declined (`false`).

  ## Returns
  - `{:ok, game}`: If the response is successful, where `game` is the updated game state.
  - `{:error, :not_in_play}`: If the game state is not in-play.
  - `{:error, :no_draw_requested}`: If there is no draw request to respond to.
  - `{:error, :cannot_respond_to_own_request}`: If the player attempts to respond to their own draw request.
  """
  def respond_to_draw(%Game{} = game, player_color, accept)
      when is_atom(player_color) and is_boolean(accept) do
    cond do
      game.state != :playing ->
        {:error, :not_in_play}

      game.draw_requested_by == nil ->
        {:error, :no_draw_request}

      game.draw_requested_by == player_color ->
        {:error, :cannot_respond_to_own_request}

      true ->
        attrs =
          if accept do
            %{
              state: :finished,
              winner: nil
            }
          else
            %{
              draw_requested_by: nil
            }
          end

        game = Repo.update!(Game.changeset(game, attrs))

        # Broadcast the game update
        Phoenix.PubSub.broadcast(
          ChessQuo.PubSub,
          "game:#{game.code}",
          {:game_updated, game}
        )

        {:ok, game}
    end
  end

  @doc """
  Checks if a game code is possibly valid. (i.e., it matches the expected format).

  ## Parameters
  - `code`: The game code to validate.

  ## Returns
  - `true`: If the code is possibly valid.
  - `false`: If the code is definitely invalid.
  """
  def possible_code?(code) do
    tokens_mod().possible_code?(code)
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
        secret = if color == :white, do: game.white_secret, else: game.black_secret

        attrs = %{
          state: "playing",
          # Both players can be set to have joined, because the host joins the game when they create it
          white_joined: true,
          black_joined: true,
          started_at: DateTime.utc_now()
        }

        game = Repo.update!(Game.changeset(game, attrs))

        # Broadcast the game update
        Phoenix.PubSub.broadcast(
          ChessQuo.PubSub,
          "game:#{game.code}",
          {:game_updated, game}
        )

        {:ok, color, secret}

      {:error, :full} = err ->
        err
    end
  end

  defp pick_slot(%{white_joined: true, black_joined: true}), do: {:error, :full}
  defp pick_slot(%{white_joined: true}), do: {:ok, :black}
  defp pick_slot(%{black_joined: true}), do: {:ok, :white}
end

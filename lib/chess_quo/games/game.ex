defmodule ChessQuo.Games.Game do
  @moduledoc """
  The Game schema and changeset logic.

  ## String Keys
  All game data uses string keys (e.g., piece["type"]) not atom keys (piece.type).
  This is consistent with how Ecto serializes the data to/from the database.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @typedoc """
  A chess piece on the board.

  ## Fields
    * `type` - The type of the piece (e.g., "pawn", "rook", "knight", etc.)
    * `color` - The color of the piece ("white" or "black")
    * `position` - The index of the piece on the board (0-63)
      - Board indices are left-to-right, top-to-bottom:
      - a1=0, b1=1, ..., h1=7
      - a2=8, b2=9, ..., h2=15
      - ...
      - a8=56, b8=57, ..., h8=63

  ## NOTE: At runtime, these keys are strings because of Ecto's serialization. This means they can not be accessed as atoms (e.g., `piece.type`), but must be accessed as strings (e.g., `piece["type"]`).
  """
  @type piece :: %{
          type: String.t(),
          color: String.t(),
          position: integer()
        }

  @typedoc """
  The board is a list of pieces.

  Each piece has a type, color, and position index.
  The board represents the current state of a chess game.
  """
  @type board :: [piece()]

  @typedoc """
  Represents a move in the game.

  ## NOTE: At runtime, these keys are strings because of Ecto's serialization. This means they can not be accessed as atoms (e.g., `piece.type`), but must be accessed as strings (e.g., `piece["type"]`).
  """
  @type move :: %{
          before: piece(),
          after: piece(),
          # Color of the player making the move
          by: String.t()
        }

  @typedoc """
  Represents the history of moves in the game.
  """
  @type history :: [move()]

  schema "games" do
    field :ruleset, :string, default: "chess"

    # Ruleset to use, check `ChessQuo.Games.Rules` (can be `chess`, `checkers`, etc., if there is a valid implementation)
    field :code, :string
    # Secret shared with the white player to verify their moves
    field :white_secret, :string
    # Secret shared with the black player to verify their moves
    field :black_secret, :string
    field :turn, :string, default: "white"
    # Type of `board`
    field :board, {:array, :map}, default: []
    # Possible states: waiting, playing, finished
    field :state, :string, default: "waiting"
    # Possible values: "white", "black", or nil if no winner yet
    field :winner, :string, default: nil
    field :white_joined, :boolean, default: false
    field :black_joined, :boolean, default: false
    # Type `history`
    field :moves, {:array, :map}, default: []

    # This is the time when the game actually started (not record creation time, this is when "state" becomes "playing")
    field :started_at, :utc_datetime
    # Used for optimistic locking
    field :lock_version, :integer, default: 0

    timestamps()
  end

  @doc false
  def system_changeset(game, attrs) do
    game
    |> change(attrs)
    |> cast(attrs, [
      :code,
      :white_secret,
      :black_secret,
      :turn,
      :board,
      :state,
      :winner,
      :white_joined,
      :black_joined,
      :moves,
      :started_at
    ])
    |> validate_required([
      :code,
      :white_secret,
      :black_secret,
      :turn,
      :board,
      :state,
      :white_joined,
      :black_joined,
      :moves
    ])
    |> unique_constraint(:code)
    |> optimistic_lock(:lock_version)
  end
end

defmodule ChessQuo.Games.Game do
  @moduledoc """
  The Game schema and changeset logic.
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
      - a8=0, b8=1, ..., h8=7
      - a7=8, b7=9, ..., h7=15
      - ...
      - a1=56, b1=57, ..., h1=63
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

  schema "games" do
    field :code, :string
    field :white_secret, :string # Secret shared with the white player to verify their moves
    field :black_secret, :string # Secret shared with the black player to verify their moves
    field :turn, :string, default: "white"
    field :board, {:array, :map}, default: [] # Type of `board`
    field :state, :string, default: "waiting" # Possible states: waiting, playing, finished
    field :winner, :string, default: nil # Possible values: "white", "black", or nil if no winner yet
    field :white_joined, :boolean, default: false
    field :black_joined, :boolean, default: false
    field :moves, {:array, :map}, default: []
    field :started_at, :utc_datetime # This is the time when the game actually started (not record creation time, this is when "state" becomes "playing")
    field :lock_version, :integer, default: 0 # Used for optimistic locking

    timestamps()
  end

  @doc false
  def system_changeset(game, attrs) do
    game
    |> change(attrs)
    |> cast(attrs, [:code, :white_secret, :black_secret, :turn, :board, :state, :winner, :white_joined, :black_joined, :moves, :started_at])
    |> validate_required([:code, :white_secret, :black_secret, :turn, :board, :state, :white_joined, :black_joined, :moves])
    |> unique_constraint(:code)
    |> optimistic_lock(:lock_version)
  end
end

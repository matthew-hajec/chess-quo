defmodule ChessQuo.Games.Game do
  @moduledoc """
  The Game schema and changeset logic.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ChessQuo.Embeds.Piece
  alias ChessQuo.Embeds.Move

  @type t :: %__MODULE__{
          ruleset: String.t(),
          code: String.t(),
          password: String.t(),
          white_secret: String.t(),
          black_secret: String.t(),
          turn: String.t(),
          state: String.t(),
          winner: String.t(),
          white_joined: boolean(),
          black_joined: boolean(),
          moves: [Move.t()],
          board: [Piece.t()],
          meta: map(),
          started_at: DateTime.t(),
          lock_version: integer()
        }

  schema "games" do
    field :ruleset, :string

    # Ruleset to use, check `ChessQuo.Games.Rules` (can be `chess`, `checkers`, etc., if there is a valid implementation)
    field :code, :string
    # Password to use for joining a game
    field :password, :string, default: ""

    # Secret shared with the white player to verify their moves
    field :white_secret, :string
    # Secret shared with the black player to verify their moves
    field :black_secret, :string

    field :turn, :string, default: "white"
    # Possible states: waiting, playing, finished
    field :state, :string, default: "waiting"
    # Possible values: "white", "black", or nil if no winner yet
    field :winner, :string, default: nil
    field :white_joined, :boolean, default: false
    field :black_joined, :boolean, default: false

    embeds_many :moves, Move, on_replace: :delete
    embeds_many :board, Piece, on_replace: :delete

    # Meta information to be used for any purpose (e.g., ruleset state, other additional data)
    field :meta, :map, default: %{}

    # This is the time when the game actually started (not record creation time, this is when "state" becomes "playing")
    field :started_at, :utc_datetime
    # Used for optimistic locking
    field :lock_version, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [
      :ruleset,
      :code,
      :password,
      :white_secret,
      :black_secret,
      :turn,
      :state,
      :winner,
      :white_joined,
      :black_joined,
      :meta,
      :started_at
    ])
    # Cast embeds
    |> cast_embed(:board, with: &Piece.changeset/2)
    |> cast_embed(:moves, with: &Move.changeset/2)
    # Required fields
    |> validate_required([:ruleset, :code, :white_secret, :black_secret])
    # Basic validations
    |> validate_length(:password, max: 30)
    |> validate_inclusion(:turn, ["white", "black"])
    |> validate_inclusion(:state, ["waiting", "playing", "finished"])
    |> unique_constraint(:code)
    # Optimistic locking
    |> optimistic_lock(:lock_version)
  end

  def build!(%__MODULE__{} = m), do: m
  def build!(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Ecto.Changeset.apply_action!(:insert)
  end

  def to_map(%__MODULE__{} = game) do
    %{
      ruleset: game.ruleset,
      code: game.code,
      password: game.password,
      white_secret: game.white_secret,
      black_secret: game.black_secret,
      turn: game.turn,
      state: game.state,
      winner: game.winner,
      white_joined: game.white_joined,
      black_joined: game.black_joined,
      moves: Enum.map(game.moves, &Move.to_map/1),
      board: Enum.map(game.board, &Piece.to_map/1),
      meta: game.meta,
      started_at: game.started_at,
      lock_version: game.lock_version
    }
  end
end

defmodule ChessQuo.Games.Game do
  @moduledoc """
  The Game schema and changeset logic.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ChessQuo.Games.Embeds.Piece
  alias ChessQuo.Games.Embeds.Move

  @type t :: %__MODULE__{
          is_local: boolean(),
          ruleset: String.t(),
          code: String.t(),
          password: String.t(),
          white_secret: String.t(),
          black_secret: String.t(),
          turn: :white | :black,
          state: :waiting | :playing | :finished,
          winner: :white | :black | nil,
          is_resignation: boolean(),
          draw_requested_by: :white | :black | nil,
          white_joined: boolean(),
          black_joined: boolean(),
          moves: [Move.t()],
          board: [Piece.t()],
          meta: map(),
          started_at: DateTime.t(),
          lock_version: integer()
        }

  schema "games" do
    field :is_local, :boolean, default: false
    field :ruleset, :string

    # Ruleset to use, check `ChessQuo.Games.Rules` (can be `chess`, `checkers`, etc., if there is a valid implementation)
    field :code, :string
    # Password to use for joining a game
    field :password, :string, default: ""

    # Secret shared with the white player to verify their moves
    field :white_secret, :string
    # Secret shared with the black player to verify their moves
    field :black_secret, :string

    field :turn, Ecto.Enum, values: [:white, :black], default: :white
    # Possible states: waiting, playing, finished
    field :state, Ecto.Enum, values: [:waiting, :playing, :finished], default: :waiting
    # Possible values: :white, :black, or nil if no winner yet
    field :winner, Ecto.Enum, values: [:white, :black], default: nil
    field :is_resignation, :boolean, default: false
    field :draw_requested_by, Ecto.Enum, values: [:white, :black], default: nil
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
      :is_local,
      :ruleset,
      :code,
      :password,
      :white_secret,
      :black_secret,
      :turn,
      :state,
      :winner,
      :is_resignation,
      :draw_requested_by,
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
      is_local: game.is_local,
      ruleset: game.ruleset,
      code: game.code,
      password: game.password,
      white_secret: game.white_secret,
      black_secret: game.black_secret,
      turn: game.turn,
      state: game.state,
      winner: game.winner,
      is_resignation: game.is_resignation,
      draw_requested_by: game.draw_requested_by,
      white_joined: game.white_joined,
      black_joined: game.black_joined,
      moves: Enum.map(game.moves, &Move.to_map/1),
      board: Enum.map(game.board, &Piece.to_map/1),
      meta: game.meta,
      started_at: game.started_at,
      lock_version: game.lock_version
    }
  end

  def debug_print_board(%__MODULE__{} = game) do
    for i <- 0..63 do
      piece = Enum.find(game.board, fn p -> p.position == i end)

      char =
        cond do
          piece == nil -> "."
          piece.type == "pawn" and piece.color == :white -> "P"
          piece.type == "rook" and piece.color == :white -> "R"
          piece.type == "knight" and piece.color == :white -> "N"
          piece.type == "bishop" and piece.color == :white -> "B"
          piece.type == "queen" and piece.color == :white -> "Q"
          piece.type == "king" and piece.color == :white -> "K"
          piece.type == "pawn" and piece.color == :black -> "p"
          piece.type == "rook" and piece.color == :black -> "r"
          piece.type == "knight" and piece.color == :black -> "n"
          piece.type == "bishop" and piece.color == :black -> "b"
          piece.type == "queen" and piece.color == :black -> "q"
          piece.type == "king" and piece.color == :black -> "k"
          true -> "?"
        end

      IO.write(char)
      if rem(i + 1, 8) == 0, do: IO.puts("")
    end

    nil
  end
end

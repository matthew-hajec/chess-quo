defmodule ChessQuo.Games.Game do
  @moduledoc """
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :code, :string
    field :white_secret, :string # Secret shared with the white player to verify their moves
    field :black_secret, :string # Secret shared with the black player to verify their moves
    field :turn, :string, default: "white"
    field :board, :map, default: %{}
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

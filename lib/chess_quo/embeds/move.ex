defmodule ChessQuo.Embeds.Move do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChessQuo.Embeds.Piece

  @type t :: %__MODULE__{from: Piece.t(), to: Piece.t()}

  @primary_key false
  embedded_schema do
    embeds_one :from, Piece
    embeds_one :to, Piece
  end

  def changeset(move, attrs) do
    move
    |> cast(attrs, [])
    |> cast_embed(:from, with: &Piece.changeset/2)
    |> cast_embed(:to, with: &Piece.changeset/2)
  end

  @doc """
  Builds a move from the given attributes.

  ## Examples
    iex> ChessQuo.Embeds.Move.build!(%{from: %{type: "pawn", color: :white, position: 12}, to: %{type: "pawn", color: :white, position: 20}})
    %ChessQuo.Embeds.Move{
      from: %ChessQuo.Embeds.Piece{type: "pawn", color: :white, position: 12},
      to: %ChessQuo.Embeds.Piece{type: "pawn", color: :white, position: 20}
    }

    iex> ChessQuo.Embeds.Move.build!(%{"from" => %{"type" => "pawn", "color" => :white, "position" => 12}, "to" => %{"type" => "pawn", "color" => :white, "position" => 20}})
    %ChessQuo.Embeds.Move{
      from: %ChessQuo.Embeds.Piece{type: "pawn", color: :white, position: 12},
      to: %ChessQuo.Embeds.Piece{type: "pawn", color: :white, position: 20}
    }

    iex> ChessQuo.Embeds.Move.build!(%ChessQuo.Embeds.Move{from: %ChessQuo.Embeds.Piece{type: "pawn", color: :white, position: 12}, to: %ChessQuo.Embeds.Piece{type: "pawn", color: :white, position: 20}})
    %ChessQuo.Embeds.Move{
      from: %ChessQuo.Embeds.Piece{type: "pawn", color: :white, position: 12},
      to: %ChessQuo.Embeds.Piece{type: "pawn", color: :white, position: 20}
    }
  """
  def build!(%__MODULE__{} = m), do: m
  def build!(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Ecto.Changeset.apply_action!(:insert)
  end

  @doc """
  Converts a move to a map.

  ## Examples
    iex> move = %ChessQuo.Embeds.Move{from: %ChessQuo.Embeds.Piece{type: "pawn", color: :white, position: 12}, to: %ChessQuo.Embeds.Piece{type: "pawn", color: :white, position: 20}}
    iex> ChessQuo.Embeds.Move.to_map(move)
    %{
      from: %{
        type: "pawn",
        color: :white,
        position: 12
      },
      to: %{
        type: "pawn",
        color: :white,
        position: 20
      }
    }
  """
  def to_map(%__MODULE__{from: from, to: to}) do
    %{
      from: Piece.to_map(from),
      to: Piece.to_map(to)
    }
  end
end

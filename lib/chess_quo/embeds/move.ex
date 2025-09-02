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

  def build!(%__MODULE__{} = m), do: m
  def build!(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Ecto.Changeset.apply_action!(:insert)
  end

  def to_map(%__MODULE__{from: from, to: to}) do
    %{
      from: Piece.to_map(from),
      to: Piece.to_map(to)
    }
  end
end

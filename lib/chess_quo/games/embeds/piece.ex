defmodule ChessQuo.Games.Embeds.Piece do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          type: String.t(),
          color: :white | :black,
          position: integer()
        }

  @primary_key false
  embedded_schema do
    # Dependent on game rules
    field :type, :string
    field :color, Ecto.Enum, values: [:white, :black]
    # 0..63
    field :position, :integer
  end

  # Changeset function for the embedded schema
  def changeset(piece, attrs) do
    piece
    |> cast(attrs, [:type, :color, :position])
    |> validate_inclusion(:position, 0..63)
    |> validate_required([:type, :color, :position])
  end

  @doc """
  Builds a piece from the given attributes.

  ## Examples
    iex> ChessQuo.Games.Embeds.Piece.build!(%{type: "pawn", color: :white, position: 12})
    %ChessQuo.Games.Embeds.Piece{type: "pawn", color: :white, position: 12}

    iex> ChessQuo.Games.Embeds.Piece.build!(%ChessQuo.Games.Embeds.Piece{type: "rook", color: :black, position: 0})
    %ChessQuo.Games.Embeds.Piece{type: "rook", color: :black, position: 0}

    iex> ChessQuo.Games.Embeds.Piece.build!(%{"type" => "bishop", "color" => :white, "position" => 35})
    %ChessQuo.Games.Embeds.Piece{type: "bishop", color: :white, position: 35}
  """
  def build!(%__MODULE__{} = m), do: m

  def build!(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Ecto.Changeset.apply_action!(:insert)
  end

  @doc """
  Converts the piece to a map.

  ## Examples
    iex> piece = %ChessQuo.Games.Embeds.Piece{type: "queen", color: :black, position: 59}
    iex> ChessQuo.Games.Embeds.Piece.to_map(piece)
    %{type: "queen", color: :black, position: 59}
  """
  def to_map(%__MODULE__{type: type, color: color, position: position}) do
    %{
      type: type,
      color: color,
      position: position
    }
  end
end

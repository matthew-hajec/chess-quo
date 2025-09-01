defmodule ChessQuo.Embeds.Piece do
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
end

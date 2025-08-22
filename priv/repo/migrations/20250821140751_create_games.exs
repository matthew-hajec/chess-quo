defmodule ChessQuo.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :code, :string, null: false
      add :white_secret, :string
      add :black_secret, :string
      add :turn, :string, default: "white"
      add :board, {:array, :map}, default: []
      add :state, :string, default: "waiting"
      add :winner, :string
      add :white_joined, :boolean, default: false
      add :black_joined, :boolean, default: false
      add :moves, {:array, :map}, default: []
      add :started_at, :utc_datetime
      add :lock_version, :integer, default: 0

      timestamps()
    end

    create unique_index(:games, [:code])
  end
end

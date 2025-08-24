defmodule ChessQuo.Repo.Migrations.AddMetaToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :meta, :map, default: %{}, null: false
    end
  end
end

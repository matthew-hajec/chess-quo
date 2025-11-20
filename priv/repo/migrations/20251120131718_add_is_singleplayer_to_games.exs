defmodule ChessQuo.Repo.Migrations.AddIsSingleplayerToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :is_singleplayer, :boolean, default: false, null: false
    end
  end
end

defmodule ChessQuo.Repo.Migrations.AddIsResignationToGame do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :is_resignation, :boolean, default: false, null: false
    end
  end
end

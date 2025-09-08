defmodule ChessQuo.Repo.Migrations.AddDrawRequestedByToGame do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :draw_requested_by, :string, null: true
    end
  end
end

defmodule ChessQuo.Repo.Migrations.AddPasswordToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :password, :string, size: 30
    end
  end
end

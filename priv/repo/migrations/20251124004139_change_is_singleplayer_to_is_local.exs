defmodule ChessQuo.Repo.Migrations.ChangeIsSingleplayerToIsLocal do
  use Ecto.Migration

  def change do
    rename table(:games), :is_singleplayer, to: :is_local
  end
end

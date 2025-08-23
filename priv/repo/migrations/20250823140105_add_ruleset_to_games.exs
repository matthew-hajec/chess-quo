defmodule ChessQuo.Repo.Migrations.AddRulesetToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :ruleset, :string, default: "chess", null: false
    end

    # Optionally create an index if you'll be querying by ruleset
    create index(:games, [:ruleset])
  end
end

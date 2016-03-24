defmodule Risen.Repo.Migrations.AddAbbreviationToSchools do
  use Ecto.Migration

  def change do
    alter table(:schools) do
      add :abbreviation, :string
    end
  end
end

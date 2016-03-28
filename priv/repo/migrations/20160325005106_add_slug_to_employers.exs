defmodule Risen.Repo.Migrations.AddSlugToEmployers do
  use Ecto.Migration

  def change do
    alter table(:employers) do
      add :slug, :string
    end
    create index(:employers, [:slug], unique: true)
  end
end

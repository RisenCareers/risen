defmodule Risen.Repo.Migrations.AddUniqueNameIndexToRoles do
  use Ecto.Migration

  def change do
    create index(:roles, [:name], unique: true)
  end
end

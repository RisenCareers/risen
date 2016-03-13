defmodule Risen.Repo.Migrations.CreateSchool do
  use Ecto.Migration

  def change do
    create table(:schools) do
      add :name, :string
      add :logo, :string
      add :slug, :string

      timestamps
    end

  end
end

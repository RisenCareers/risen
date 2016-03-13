defmodule Risen.Repo.Migrations.CreateMajor do
  use Ecto.Migration

  def change do
    create table(:majors) do
      add :name, :string

      timestamps
    end

  end
end

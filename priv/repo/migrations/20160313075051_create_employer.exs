defmodule Risen.Repo.Migrations.CreateEmployer do
  use Ecto.Migration

  def change do
    create table(:employers) do
      add :name, :string
      add :logo, :string

      timestamps
    end

  end
end

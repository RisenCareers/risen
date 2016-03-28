defmodule Risen.Repo.Migrations.AddBackPicFields do
  use Ecto.Migration

  def change do
    alter table(:employers) do
      add :logo, :string
    end
    alter table(:students) do
      add :pic, :string
    end
  end
end

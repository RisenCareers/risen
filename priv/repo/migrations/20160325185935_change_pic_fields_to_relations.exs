defmodule Risen.Repo.Migrations.ChangePicFieldsToRelations do
  use Ecto.Migration

  def change do
    alter table(:employers) do
      remove :logo
    end
    alter table(:students) do
      remove :pic
    end
  end
end

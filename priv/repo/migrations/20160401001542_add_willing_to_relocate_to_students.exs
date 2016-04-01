defmodule Risen.Repo.Migrations.AddWillingToRelocateToStudents do
  use Ecto.Migration

  def change do
    alter table(:students) do
      add :is_willing_to_relocate, :boolean, default: false
    end
  end
end

defmodule Risen.Repo.Migrations.AddRemovedAtToEmployerMajors do
  use Ecto.Migration

  def change do
    alter table(:employer_majors) do
      add :removed_at, :datetime
    end
  end
end

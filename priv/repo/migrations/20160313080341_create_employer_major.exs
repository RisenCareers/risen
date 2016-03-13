defmodule Risen.Repo.Migrations.CreateEmployerMajor do
  use Ecto.Migration

  def change do
    create table(:employer_majors) do
      add :employer_id, references(:employers, on_delete: :nothing)
      add :major_id, references(:majors, on_delete: :nothing)

      timestamps
    end
    create index(:employer_majors, [:employer_id])
    create index(:employer_majors, [:major_id])

  end
end

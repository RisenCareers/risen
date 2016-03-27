defmodule Risen.Repo.Migrations.CreateEmployerStudentInterest do
  use Ecto.Migration

  def change do
    create table(:employer_student_interests) do
      add :employer_id, references(:employers, on_delete: :nothing)
      add :student_id, references(:students, on_delete: :nothing)

      timestamps
    end
    create index(:employer_student_interests, [:employer_id, :student_id], unique: true)

  end
end

defmodule Risen.Repo.Migrations.CreateBatchStudent do
  use Ecto.Migration

  def change do
    create table(:batch_students) do
      add :batch_id, references(:batches, on_delete: :nothing)
      add :student_id, references(:students, on_delete: :nothing)

      timestamps
    end
    create index(:batch_students, [:batch_id])
    create index(:batch_students, [:student_id])

  end
end

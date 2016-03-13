defmodule Risen.Repo.Migrations.CreateStudent do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :name, :string
      add :pic, :string
      add :resume, :string
      add :phone, :string
      add :visa_status, :string
      add :job_type, :string
      add :location_preference, :string
      add :status, :string
      add :school_id, references(:schools, on_delete: :nothing)
      add :major_id, references(:majors, on_delete: :nothing)

      timestamps
    end
    create index(:students, [:school_id])

  end
end

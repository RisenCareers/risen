defmodule Risen.Repo.Migrations.AddIsCurrentToEmployerMajors do
  use Ecto.Migration

  def change do
    alter table(:employer_majors) do
      add :is_current, :boolean, default: true
    end
  end
end

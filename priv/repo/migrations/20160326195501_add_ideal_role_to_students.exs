defmodule Risen.Repo.Migrations.AddIdealRoleToStudents do
  use Ecto.Migration

  def change do
    alter table(:students) do
      add :ideal_role, :string
    end
  end
end

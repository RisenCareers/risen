defmodule Risen.Repo.Migrations.AddAccountToStudents do
  use Ecto.Migration

  def change do
    alter table(:students) do
      add :account_id, references(:accounts, on_delete: :nothing)
    end
  end
end

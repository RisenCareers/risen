defmodule Risen.Repo.Migrations.AddEmployerAdmins do
  use Ecto.Migration

  def change do
    create table(:employer_admins) do
      add :employer_id, references(:employers, on_delete: :nothing)
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps
    end
    create index(:employer_admins, [:employer_id, :account_id], unique: true)
  end
end

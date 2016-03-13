defmodule Risen.Repo.Migrations.CreateAccountRole do
  use Ecto.Migration

  def change do
    create table(:account_roles) do
      add :account_id, references(:accounts, on_delete: :nothing)
      add :role_id, references(:roles, on_delete: :nothing)

      timestamps
    end
    create index(:account_roles, [:account_id])
    create index(:account_roles, [:role_id])

  end
end

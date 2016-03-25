defmodule Risen.Repo.Migrations.AddUniqueIndexToAccounts do
  use Ecto.Migration

  def change do
    create unique_index(:accounts, [:email])
  end
end

defmodule Risen.Repo.Migrations.CreateBatch do
  use Ecto.Migration

  def change do
    create table(:batches) do
      add :sent_at, :datetime

      timestamps
    end

  end
end

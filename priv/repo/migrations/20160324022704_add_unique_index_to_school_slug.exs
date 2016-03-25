defmodule Risen.Repo.Migrations.AddUniqueIndexToSchoolSlug do
  use Ecto.Migration

  def change do
    create unique_index(:schools, [:slug])
  end
end

defmodule Risen.School do
  use Risen.Web, :model

  schema "schools" do
    field :name, :string
    field :logo, :string
    field :abbreviation, :string
    field :slug, :string

    has_many :students, Risen.Student
    timestamps
  end

  @required_fields ~w(name abbreviation)
  @optional_fields ~w(logo)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> slugify_name
    |> unique_constraint(:slug)
  end

  defp slugify_name(changeset) do
    if abbreviation = get_change(changeset, :abbreviation) do
      put_change(changeset, :slug, Slugger.slugify_downcase(abbreviation))
    else
      changeset
    end
  end
end

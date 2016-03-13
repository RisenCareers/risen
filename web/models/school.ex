defmodule Risen.School do
  use Risen.Web, :model

  schema "schools" do
    field :name, :string
    field :logo, :string
    field :slug, :string

    has_many :students, Risen.Student
    timestamps
  end

  @required_fields ~w(name logo slug)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

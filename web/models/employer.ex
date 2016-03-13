defmodule Risen.Employer do
  use Risen.Web, :model

  schema "employers" do
    field :name, :string
    field :logo, :string

    has_many :employer_majors, Risen.EmployerMajor
    has_many :majors, through: [:employer_majors, :major]
    timestamps
  end

  @required_fields ~w(name logo)
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

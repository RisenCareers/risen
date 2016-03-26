defmodule Risen.Employer do
  use Risen.Web, :model

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "employers" do
    field :name, :string
    field :slug, :string
    field :logo, :string

    has_many :employer_majors, Risen.EmployerMajor
    has_many :majors, through: [:employer_majors, :major]
    has_many :employer_admins, Risen.EmployerAdmin
    has_many :admins, through: [:employer_admins, :account]
    timestamps
  end

  @required_fields ~w(name slug)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> update_change(:slug, &String.downcase/1)
    |> unique_constraint(:slug)
  end
end

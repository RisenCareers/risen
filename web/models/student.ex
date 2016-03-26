defmodule Risen.Student do
  use Risen.Web, :model

  schema "students" do
    field :name, :string
    field :resume, :string
    field :phone, :string
    field :visa_status, :string
    field :job_type, :string
    field :location_preference, :string
    field :status, :string

    belongs_to :account, Risen.Account
    belongs_to :school, Risen.School
    belongs_to :major, Risen.Major

    timestamps
  end

  @required_fields ~w(name account_id)
  @optional_fields ~w(resume phone visa_status job_type location_preference status)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:name, min: 2)
  end
end

defmodule Risen.Student do
  use Risen.Web, :model

  schema "students" do
    field :name, :string
    field :phone, :string
    field :ideal_role, :string
    field :visa_status, :string
    field :job_type, :string
    field :location_preference, :string
    field :is_willing_to_relocate, :boolean
    field :pic, :string
    field :resume, :string
    field :status, :string

    belongs_to :account, Risen.Account
    belongs_to :school, Risen.School
    belongs_to :major, Risen.Major

    timestamps
  end

  @required_base_fields ~w(name account_id school_id)
  @optional_base_fields ~w(phone ideal_role visa_status job_type location_preference is_willing_to_relocate pic resume major_id status)

  @required_profile_fields ~w(ideal_role visa_status job_type location_preference pic resume major_id)
  @optional_profile_fields ~w(is_willing_to_relocate status)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_base_fields, @optional_base_fields)
    |> base_changeset
  end

  def profile_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_profile_fields, @optional_profile_fields)
    |> base_changeset
  end

  def base_changeset(model, params \\ :empty) do
    model
    |> validate_length(:name, min: 2)
  end

  def visa_statuses() do
    [
      "Eligible to work in the US",
      "Requires work permit now",
      "Will need work permit in the future"
    ]
  end

  def job_types() do
    [
      "Full-time",
      "Part-time",
      "Contract",
      "Short-Term",
      "Internship"
    ]
  end

  def statuses() do
    [
      "Pending"
    ]
  end
end

defmodule Risen.EmployerStudentInterest do
  use Risen.Web, :model

  schema "employer_student_interests" do
    belongs_to :employer, Risen.Employer
    belongs_to :student, Risen.Student

    timestamps
  end

  @required_fields ~w(employer_id, student_id)
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

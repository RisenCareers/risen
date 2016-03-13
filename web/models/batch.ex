defmodule Risen.Batch do
  use Risen.Web, :model

  schema "batches" do
    field :sent_at, Ecto.DateTime

    has_many :batch_students, Risen.BatchStudent
    has_many :students, through: [:batch_students, :student]
    timestamps
  end

  @required_fields ~w(sent_at)
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

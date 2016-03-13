defmodule Risen.AccountRole do
  use Risen.Web, :model

  schema "account_roles" do
    belongs_to :account, Risen.Account
    belongs_to :role, Risen.Role

    timestamps
  end

  @required_fields ~w()
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

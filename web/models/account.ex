defmodule Risen.Account do
  use Risen.Web, :model

  schema "accounts" do
    field :email, :string
    field :password_hash, :string

    has_many :account_roles, Risen.AccountRole
    has_many :roles, through: [:account_roles, :role]
    timestamps
  end

  @required_fields ~w(email password_hash)
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

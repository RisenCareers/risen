defmodule Risen.Account do
  use Risen.Web, :model

  import Comeonin.Bcrypt

  schema "accounts" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :account_roles, Risen.AccountRole
    has_many :roles, through: [:account_roles, :role]

    has_many :employer_admins, Risen.EmployerAdmin
    has_many :employers, through: [:employer_admins, :employer]

    has_many :students, Risen.Student
    timestamps
  end

  @required_fields ~w(email password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> hash_password
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password_hash, hashpwsalt(password))
    else
      changeset
    end
  end

  def has_role?(model, role) do
    model = Risen.Repo.preload(model, [:roles])
    Enum.member?(Enum.map(model.roles, fn(r) -> r.name end), role)
  end
end

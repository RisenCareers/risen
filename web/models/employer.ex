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
    has_many :students, through: [:employer_majors, :major]
    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(logo)

  @required_settings_fields ~w(logo)
  @optional_settings_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> slugify_name
    |> validate_length(:name, min: 2)
    |> unique_constraint(:slug)
  end

  def settings_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_settings_fields, @optional_settings_fields)
  end

  defp slugify_name(changeset) do
    if name = get_change(changeset, :name) do
      put_change(changeset, :slug, Slugger.slugify_downcase(name))
    else
      changeset
    end
  end
end

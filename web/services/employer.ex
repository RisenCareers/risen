defmodule Risen.EmployerService do
  import Ecto.Query, only: [from: 1, from: 2]

  alias Risen.Repo
  alias Risen.Role
  alias Risen.AccountRole
  alias Risen.EmployerLogo
  alias Risen.Employer
  alias Risen.EmployerMajor

  def create_admin(model) do
    admin = Repo.insert!(model)
    role = Repo.get_by(Role, name: "EmployerAdmin")
    Repo.insert!(%AccountRole{
      account_id: admin.account_id,
      role_id: role.id
    })
    admin
  end

  def upload_logo(conn, logo_param) do
    employer = conn.assigns[:employer]
    if logo_param do
      case EmployerLogo.store({logo_param, employer}) do
        {:ok, _} ->
          employer_changeset = Employer.changeset(employer, %{
            "logo" => logo_param.filename
          })
          Repo.update(employer_changeset)
        {:error, error} -> {:error, error}
      end
    else
      {:ok, employer}
    end
  end

  def save_majors(conn, majors_param) do
    employer = conn.assigns[:employer]

    # Remove all current employer majors
    Ecto.Query.from(
      em in EmployerMajor,
      where: em.employer_id == ^employer.id
    )
    |> Repo.delete_all

    # Update the employer interests
    if majors_param do
      Enum.each(majors_param, fn m ->
        Repo.insert!(%EmployerMajor{
          major_id: String.to_integer(m),
          employer_id: employer.id
        })
      end)
    end

    {:ok, employer}
  end
end

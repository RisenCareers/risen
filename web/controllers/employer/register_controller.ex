defmodule Risen.Employer.RegisterController do
  use Risen.Web, :controller
  import Comeonin.Bcrypt

  alias Risen.Account
  alias Risen.AccountRole
  alias Risen.Role
  alias Risen.Employer

  plug Risen.Employer.Plugs.Authenticator when action in [:setup_get, :setup_update]
  plug :put_layout, "employer.html"
  plug :scrub_params, "employer" when action in [:create, :update]

  def register_get(conn, _params) do
    changeset = Employer.changeset(%Employer{})
    render conn, "register.html", changeset: changeset
  end

  def register_post(conn, params) do

    # Hash the password for security
    hash = hashpwsalt(params["employer"]["password"])

    # Create the changes for the account
    account_changeset = Account.changeset(
      %Account{},
      %{ "email" => params["employer"]["email"], "password_hash" => hash }
    )

    case Repo.insert(account_changeset) do
      {:ok, account} ->

        # Add the Employer Admin role to the account
        role = Repo.get_by(Role, name: "EmployerAdmin")
        Repo.insert!(%AccountRole{
          account_id: account.id,
          role_id: role.id
        })

        # Create the employer
        employer_changeset = Employer.changeset(%Employer{}, %{
          name: params["employer"]["name"],
          slug: params["employer"]["slug"]
        })
        employer = Repo.insert!(employer_changeset)

        # Create the employer admin
        Repo.insert!(%Risen.EmployerAdmin{
          account_id: account.id,
          employer_id: employer.id
        })

        conn
        |> put_session(:account_id, account.id)
        |> put_flash(:info, "Organization created successfully.")
        |> redirect(to: employer_register_path(conn, :setup_get, employer.slug))

      {:error, changeset} ->
        render(conn, "register.html", changeset: changeset)
    end
  end

  def setup_get(conn, params) do

    # We got our employer from the Employer authenticator plug
    employer = conn.assigns[:employer]

    # Preload the majors
    employer = Repo.preload(employer, [:majors])

    majors = Repo.all(from m in Risen.Major)
    changeset = Employer.changeset(employer)

    render conn, "setup.html", employer: employer, changeset: changeset, majors: majors

  end

  def setup_update(conn, params) do

    # We got our employer from the Employer authenticator plug
    employer = conn.assigns[:employer]

    # Preload the majors
    employer = Repo.preload(employer, [:majors])

    # Update the employer logo
    if params["logo"] do
      Risen.EmployerLogo.store({params["logo"], employer})
      employer_changeset = Ecto.Changeset.change(employer, logo: params["logo"].filename)
      employer = Repo.update!(employer_changeset)
    end

    # Remove all current employer majors
    Ecto.Query.from(
      em in Risen.EmployerMajor,
      where: em.employer_id == ^employer.id
    )
    |> Repo.delete_all

    # Update the employer interests
    if params["employer"]["majors"] do
      Repo.transaction fn ->
        Enum.each(params["employer"]["majors"], fn m ->
          {m_id, _} = Integer.parse(m)
          Repo.insert!(%Risen.EmployerMajor{
            major_id: m_id,
            employer_id: employer.id
          })
        end)
      end
    end

    conn
    |> redirect(to: employer_students_path(conn, :index, employer.slug))
    |> halt()

  end
end

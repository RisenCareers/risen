defmodule Risen.Employer.RegisterController do
  use Risen.Web, :controller
  import Comeonin.Bcrypt

  alias Risen.Account
  alias Risen.AccountRole
  alias Risen.Role
  alias Risen.Employer
  alias Risen.EmployerAdmin

  plug :scrub_params, "employer" when action in [:create, :update]
  plug :put_layout, "employer.html"

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
        Repo.insert!(%EmployerAdmin{
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

    # Get the account tied to the session
    account_id = get_session(conn, :account_id)

    unless account_id do
      conn
      |> redirect(to: employer_register_path(conn, :register_get))
      |> halt()
    end

    # Retrieve the employer based on the URL, preloading admins
    employer = Repo.get_by(Employer, slug: params["employer_slug"])

    unless employer do
      conn
      |> redirect(to: employer_register_path(conn, :register_get))
      |> halt()
    end

    # Retrieve the account in the session
    account = Repo.get(Account, account_id)

    # Preload the employer admins
    employer = Repo.preload(employer, [:admins])

    # Check if account is an employer admin
    unless Enum.member?(employer.admins, account) do
      conn
      |> redirect(to: employer_register_path(conn, :register_get))
      |> halt()
    end

    majors = Repo.all(from m in Risen.Major)
    changeset = Employer.changeset(%Employer{})
    render conn, "setup.html", employer: employer, changeset: changeset, majors: majors

  end

  def setup_post(conn, params) do

    # Get the account tied to the session
    account_id = get_session(conn, :account_id)

    unless account_id do
      conn
      |> redirect(to: employer_register_path(conn, :register_get))
      |> halt()
    end

    # Retrieve the employer based on the URL, preloading admins
    employer = Repo.get_by(Employer, slug: params["employer_slug"])

    unless employer do
      conn
      |> redirect(to: employer_register_path(conn, :register_get))
      |> halt()
    end

    # Retrieve the account in the session
    account = Repo.get(Account, account_id)

    # Preload the employer admins
    employer = Repo.preload(employer, [:admins])

    # Check if account is an employer admin
    unless Enum.member?(employer.admins, account) do
      conn
      |> redirect(to: employer_register_path(conn, :register_get))
      |> halt()
    end

    # Update the employer logo
    Risen.EmployerLogo.store({params["logo"], employer})

    # Remove all current employer majors
    Ecto.Query.from(
      em in Risen.EmployerMajor,
      where: em.employer_id == ^employer.id
    )
    |> Repo.delete_all

    # Update the employer interests
    Repo.transaction fn ->
      Enum.each(params["employer"]["majors"], fn m ->
        {m_id, _} = Integer.parse(m)
        Repo.insert!(%Risen.EmployerMajor{
          major_id: m_id,
          employer_id: employer.id
        })
      end)
    end

    conn
    |> redirect(to: employer_students_path(conn, :index, employer.slug))
    |> halt()

  end
end

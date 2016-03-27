defmodule Risen.Employer.RegisterController do
  use Risen.Web, :controller

  import Comeonin.Bcrypt

  alias Risen.Account
  alias Risen.AccountRole
  alias Risen.Role
  alias Risen.Employer
  alias Risen.EmployerAdmin

  plug :put_layout, "employer.html"
  plug :scrub_params, "employer" when action in [:create]

  def new(conn, _params) do
    changeset = Employer.changeset(%Employer{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, params) do

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
        |> redirect(to: employer_setup_path(conn, :edit, employer.slug))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

end

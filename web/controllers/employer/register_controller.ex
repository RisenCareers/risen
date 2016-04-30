defmodule Risen.Employer.RegisterController do
  use Risen.Web, :controller

  import Comeonin.Bcrypt

  alias Risen.Account
  alias Risen.AccountRole
  alias Risen.Role
  alias Risen.Employer
  alias Risen.EmployerAdmin
  alias Risen.EmployerService

  plug :put_layout, "employer.html"
  plug :scrub_params, "employer" when action in [:create]

  def new(conn, _params) do
    conn
    |> assign(:errors, [])
    |> render("new.html")
  end

  def create(conn, params) do
    # This is kind of a mess. It will get better (MUCH) in Ecto 2.0
    account_changeset = Account.changeset(%Account{}, params["account"])
    employer_changeset = Employer.changeset(%Employer{}, params["employer"])

    # Wrap the creation of things in a transaction.
    # If one fails, WE ALL FAIL
    tx_result = Repo.transaction fn ->
      # Create the employer
      case Repo.insert(employer_changeset) do
        {:ok, employer} ->
          # Create the employer admin
          case Repo.insert(account_changeset) do
            {:ok, account} ->
              EmployerService.create_admin(%EmployerAdmin{
                account_id: account.id,
                employer_id: employer.id
              })
              Risen.Mailer.send_employer_welcome_email(employer)
              conn
              |> put_session(:account_id, account.id)
              |> redirect(to: employer_setup_path(conn, :edit, employer.slug))
            {:error, account_changeset} ->
              errors = Ecto.Changeset.traverse_errors(account_changeset, &Risen.ErrorHelpers.translate_error/1)
              conn
              |> assign(:errors, errors)
              |> render("new.html")
              |> Repo.rollback
          end
        {:error, employer_changeset} ->
          errors = Ecto.Changeset.traverse_errors(employer_changeset, &Risen.ErrorHelpers.translate_error/1)
          conn
          |> assign(:errors, errors)
          |> render("new.html")
          |> Repo.rollback
      end
    end

    case tx_result do
      {:ok, conn} -> conn
      {:error, conn} -> conn
    end
  end

end

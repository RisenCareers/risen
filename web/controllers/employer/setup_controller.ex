defmodule Risen.Employer.SetupController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Employer.Authenticator

  alias Risen.Employer
  alias Risen.EmployerLogo
  alias Risen.EmployerMajor
  alias Risen.Major
  alias Risen.EmployerService

  plug :authenticate
  plug :require_employer
  plug :require_employer_admin
  plug :load_employer_majors
  plug :load_all_majors
  plug :put_layout, "employer.html"
  plug :scrub_params, "employer" when action in [:update]

  def edit(conn, _params) do
    employer = conn.assigns[:employer]
    changeset = Employer.changeset(employer)

    conn
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, params) do
    # We got our employer from the Employer authenticator plug
    employer = conn.assigns[:employer]
    changeset = Employer.changeset(employer)

    tx_result = Repo.transaction fn ->
      case EmployerService.upload_logo(conn, conn.params["logo"]) do
        {:ok, employer} ->
          case EmployerService.save_majors(conn, conn.params["employer"]["majors"]) do
            {:ok, employer} ->
              conn
              |> redirect(to: employer_students_path(conn, :index, employer.slug))
            {:error, _} ->
              changeset = Ecto.Changeset.add_error(changeset, :logo, "errored uploading")
              conn
              |> assign(:changeset, changeset)
              |> render("edit.html")
              |> Repo.rollback
          end
        {:error, _} ->
          changeset = Ecto.Changeset.add_error(changeset, :logo, "errored uploading")
          conn
          |> assign(:changeset, changeset)
          |> render("edit.html")
          |> Repo.rollback
      end
    end

    elem(tx_result, 1)
  end

  defp load_all_majors(conn, _) do
    majors = Repo.all(from m in Major)
    conn |> assign(:majors, majors)
  end

  defp load_employer_majors(conn, _) do
    employer = conn.assigns[:employer]
    employer = Repo.preload(employer, [:majors])
    conn |> assign(:employer, employer)
  end

end

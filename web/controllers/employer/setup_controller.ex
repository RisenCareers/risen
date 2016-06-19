defmodule Risen.Employer.SetupController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Employer.Authenticator

  alias Risen.Employer
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
    employer = conn.assigns[:employer]
    conn |> EmployerService.save_settings(employer, "edit.html", fn(c) ->
      c |> redirect(to: employer_batches_path(conn, :index, employer.slug))
    end)
  end

  defp load_all_majors(conn, _) do
    majors = Repo.all(from m in Major)
    conn |> assign(:majors, majors)
  end

  defp load_employer_majors(conn, _) do
    employer = conn.assigns[:employer]
    employer = EmployerService.load_current_majors(employer)
    conn |> assign(:employer, employer)
  end

end

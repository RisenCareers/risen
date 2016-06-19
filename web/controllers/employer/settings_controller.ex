defmodule Risen.Employer.SettingsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Employer.Authenticator

  alias Ecto.Changeset

  alias Risen.Employer
  alias Risen.EmployerLogo
  alias Risen.EmployerMajor
  alias Risen.EmployerService
  alias Risen.Major

  plug :put_layout, "employer.html"
  plug :authenticate
  plug :require_employer
  plug :require_employer_admin
  plug :load_employer_majors
  plug :load_all_majors
  plug :scrub_params, "employer" when action in [:update]

  def show(conn, _params) do
    employer = conn.assigns[:employer]
    changeset = Employer.changeset(employer)

    conn
    |> assign(:changeset, changeset)
    |> render("show.html")
  end

  def update(conn, params) do
    employer = conn.assigns[:employer]
    conn |> EmployerService.save_settings(employer, "show.html", fn(c) ->
      c
      |> put_flash(:success, "Settings updated successfully")
      |> redirect(to: employer_settings_path(conn, :show, employer.slug))
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

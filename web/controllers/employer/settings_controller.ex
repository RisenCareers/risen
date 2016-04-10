defmodule Risen.Employer.SettingsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Employer.Authenticator

  alias Risen.Employer
  alias Risen.EmployerLogo
  alias Risen.EmployerMajor
  alias Risen.Major

  plug :put_layout, "employer.html"
  plug :authenticate
  plug :require_employer
  plug :require_employer_admin
  plug :scrub_params, "employer" when action in [:update]

  def show(conn, _params) do
    # Retrieve employer via the Authenticator plug
    employer = conn.assigns[:employer]

    # Preload the majors
    employer = Repo.preload(employer, [:majors])

    majors = Repo.all(from m in Major)
    changeset = Employer.changeset(employer)

    conn
    |> assign(:employer, employer)
    |> assign(:majors, majors)
    |> assign(:changeset, changeset)
    |> render("show.html")
  end

  def update(conn, params) do
    # We got our employer from the Employer authenticator plug
    employer = conn.assigns[:employer]

    # Preload the majors
    employer = Repo.preload(employer, [:majors])

    # Update the employer logo
    if params["logo"] do
      EmployerLogo.store({params["logo"], employer})
      employer_changeset = Ecto.Changeset.change(employer, logo: params["logo"].filename)
      employer = Repo.update!(employer_changeset)
    end

    # Remove all current employer majors
    Ecto.Query.from(
      em in EmployerMajor,
      where: em.employer_id == ^employer.id
    )
    |> Repo.delete_all

    # Update the employer interests
    if params["employer"]["majors"] do
      Repo.transaction fn ->
        Enum.each(params["employer"]["majors"], fn m ->
          {m_id, _} = Integer.parse(m)
          Repo.insert!(%EmployerMajor{
            major_id: m_id,
            employer_id: employer.id
          })
        end)
      end
    end

    conn
    |> put_flash(:success, "Settings saved successfully")
    |> redirect(to: employer_settings_path(conn, :show, employer.slug))
    |> halt()
  end
end

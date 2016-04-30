defmodule Risen.Admin.SchoolsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.School
  alias Risen.SchoolLogo

  plug :authenticate
  plug :require_admin
  plug :load_school when action in [:edit, :update, :delete]
  plug :put_layout, "admin.html"

  def index(conn, _params) do
    schools = Repo.all(
      from e in School,
      preload: [:students]
    )

    conn
    |> assign(:schools, schools)
    |> render("index.html")
  end

  def new(conn, _params) do
    school_changeset = School.changeset(%School{})

    conn
    |> assign(:changeset, school_changeset)
    |> render("new.html")
  end

  def create(conn, params) do
    school_changeset = School.changeset(%School{}, params["school"])
    school = Repo.insert!(school_changeset)

    # Update the school logo, if specified
    if params["logo"] do
      SchoolLogo.store({params["logo"], school})
      school_changeset = Ecto.Changeset.change(school, logo: params["logo"].filename)
      Repo.update!(school_changeset)
    end

    conn
    |> redirect(to: admin_schools_path(conn, :index))
    |> halt()
  end

  def edit(conn, _params) do
    school = conn.assigns[:school]
    school_changeset = School.changeset(school)

    conn
    |> assign(:changeset, school_changeset)
    |> render("edit.html")
  end

  def update(conn, params) do
    school = conn.assigns[:school]
    school_changeset = School.changeset(school, params["school"])
    school = Repo.update!(school_changeset)

    # Update the school logo, if specified
    if params["logo"] do
      SchoolLogo.store({params["logo"], school})
      school_changeset = Ecto.Changeset.change(school, logo: params["logo"].filename)
      Repo.update!(school_changeset)
    end

    conn
    |> put_flash(:success, "School saved successfully")
    |> redirect(to: admin_schools_path(conn, :edit, school.id))
  end

  def delete(conn, params) do
    school = conn.assigns[:school]
    Repo.delete!(school)

    conn
    |> put_flash(:success, "School deleted successfully")
    |> redirect(to: admin_schools_path(conn, :index))
  end

  defp load_school(conn, _) do
    school = Repo.get(School, conn.params["id"])
    conn |> assign(:school, school)
  end

end

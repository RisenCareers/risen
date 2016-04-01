defmodule Risen.Admin.SchoolsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.School
  alias Risen.SchoolLogo

  plug :authenticate
  plug :require_admin
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
      school = Repo.update!(school_changeset)
    end

    conn
    |> redirect(to: admin_schools_path(conn, :index))
    |> halt()
  end

end

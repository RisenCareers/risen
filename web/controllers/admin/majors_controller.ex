defmodule Risen.Admin.MajorsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.Major

  plug :authenticate
  plug :require_admin
  plug :load_major when action in [:edit, :update, :delete]
  plug :put_layout, "admin.html"

  def index(conn, _params) do
    majors = Repo.all(from m in Major)

    conn
    |> assign(:majors, majors)
    |> render("index.html")
  end

  def new(conn, _params) do
    major_changeset = Major.changeset(%Major{})

    conn
    |> assign(:changeset, major_changeset)
    |> render("new.html")
  end

  def create(conn, params) do
    major_changeset = Major.changeset(%Major{}, params["major"])
    major = Repo.insert!(major_changeset)

    conn
    |> put_flash(:success, "Major created successfully")
    |> redirect(to: admin_majors_path(conn, :index))
    |> halt()
  end

  def edit(conn, _params) do
    major = conn.assigns[:major]
    major_changeset = Major.changeset(major)

    conn
    |> assign(:changeset, major_changeset)
    |> render("edit.html")
  end

  def update(conn, params) do
    major = conn.assigns[:major]
    major_changeset = Major.changeset(major, params["major"])
    major = Repo.update!(major_changeset)

    conn
    |> put_flash(:success, "Major saved successfully")
    |> redirect(to: admin_majors_path(conn, :edit, major.id))
  end

  def delete(conn, params) do
    major = conn.assigns[:major]
    Repo.delete!(major)

    conn
    |> put_flash(:success, "Major deleted successfully")
    |> redirect(to: admin_majors_path(conn, :index))
  end

  defp load_major(conn, _) do
    major = Repo.get(Major, conn.params["id"])
    conn |> assign(:major, major)
  end

end

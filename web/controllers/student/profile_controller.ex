defmodule Risen.Student.ProfileController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Student.Authenticator

  alias Ecto.Changeset

  alias Risen.Repo
  alias Risen.Student
  alias Risen.School
  alias Risen.Major
  alias Risen.StudentService

  plug :authenticate
  plug :require_student
  plug :load_school
  plug :load_majors
  plug :put_layout, "student.html"
  plug :scrub_params, "student" when action in [:update]

  def edit(conn, _params) do
    student = conn.assigns[:student]
    changeset = Ecto.Changeset.change(student)

    conn
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, params) do
    student = conn.assigns[:student]

    st_prms = params["student"]
    if params["pic"], do: st_prms = Map.put(st_prms, "pic", params["pic"].filename)
    if params["resume"], do: st_prms = Map.put(st_prms, "resume", params["resume"].filename)
    st_chgs = Student.profile_changeset(student, st_prms)

    case StudentService.upload_pic(conn, params["pic"]) do
      {:ok, student} ->
        conn = assign(conn, :student, student)
        case StudentService.upload_resume(conn, params["resume"]) do
          {:ok, student} ->
            conn = assign(conn, :student, student)
            case Repo.update(st_chgs) do
              {:ok, student} ->
                conn
                |> put_flash(:success, "Profile saved successfully.")
                |> redirect(to: student_profile_path(conn, :edit, student.id))
              {:error, st_chgs} ->
                conn |> error_updating(st_chgs)
            end
          {:error, _} ->
            st_chgs = Changeset.add_error(st_chgs, :resume, "errored uploading")
            conn |> error_updating(st_chgs)
        end
      {:error, _} ->
        st_chgs = Changeset.add_error(st_chgs, :pic, "errored uploading")
        conn |> error_updating(st_chgs)
    end
  end

  defp load_school(conn, _) do
    school = Repo.get(School, conn.assigns[:student].school_id)
    conn |> assign(:school, school)
  end

  defp load_majors(conn, _) do
    majors = Repo.all(Major)
    conn |> assign(:majors, majors)
  end

  defp error_updating(conn, changeset) do
    conn
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end
end

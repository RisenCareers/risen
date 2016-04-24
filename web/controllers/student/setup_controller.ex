defmodule Risen.Student.SetupController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Student.Authenticator

  alias Ecto.Changeset
  alias Risen.Student
  alias Risen.School
  alias Risen.StudentService

  plug :authenticate
  plug :require_student
  plug :load_school
  plug :load_majors
  plug :put_layout, "student.html"
  plug :scrub_params, "student" when action in [:update]

  def edit(conn, _params) do
    student = conn.assigns[:student]
    changeset = Changeset.change(student)

    conn
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, params) do
    school = conn.assigns[:school]
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
                conn |> redirect(to: student_setup_path(conn, :done, school.slug, student.id))
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

  def done(conn, _params) do
    render conn, "done.html"
  end

  defp error_updating(conn, changeset) do
    conn
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  defp load_school(conn, _) do
    school = Repo.get_by(School, slug: conn.params["school_slug"])
    unless school do
      conn |> bad_request("Invalid school.")
    else
      conn |> assign(:school, school)
    end
  end

  defp load_majors(conn, _) do
    majors = Repo.all(Risen.Major)
    conn |> assign(:majors, majors)
  end

  defp bad_request(conn, error) do
    conn
    |> put_flash(:error, error)
    |> redirect(to: home_path(conn, :index))
    |> halt()
  end
end

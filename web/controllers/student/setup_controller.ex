defmodule Risen.Student.SetupController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator

  alias Risen.Student
  alias Risen.School
  alias Risen.StudentPic
  alias Risen.StudentResume

  plug :put_layout, "student.html"
  plug :authenticate
  plug :load_school
  plug :load_student
  plug :load_majors
  plug :scrub_params, "student" when action in [:update]

  def edit(conn, _params) do
    student = conn.assigns[:student]
    changeset = Ecto.Changeset.change(student)

    conn
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, params) do
    school = conn.assigns[:school]
    student = conn.assigns[:student]

    student_params = params["student"]

    student_changeset = Student.changeset(
      student,
      Map.merge(student_params, %{ "status" => "Pending" })
    )
    student = Repo.update!(student_changeset)

    Enum.each([{StudentPic, "pic"}, {StudentResume, "resume"}], fn({ m, p }) ->
      if params[p] do
        m.store({params[p], student})
        student_changeset = Student.changeset(student, %{ p => params[p].filename })
        student = Repo.update!(student_changeset)
      end
    end)

    conn
    |> put_flash(:info, "Student setup successfully.")
    |> redirect(to: student_setup_path(conn, :done, school.slug, student.id))
  end

  def done(conn, _params) do
    render conn, "done.html"
  end

  defp load_school(conn, _) do
    school = Repo.get_by(School, slug: conn.params["school_slug"])
    unless school do
      conn |> bad_request("Invalid school.")
    else
      conn |> assign(:school, school)
    end
  end

  defp load_student(conn, _) do
    student = Repo.get(Student, conn.params["id"])
    student = Repo.preload(student, [:major])
    unless student do
      conn |> bad_request("No student.")
    else
      unless student.account_id == conn.assigns[:account].id do
        conn |> bad_request("Not authorized to setup this student.")
      else
        conn |> assign(:student, student)
      end
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

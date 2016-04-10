defmodule Risen.Student.ProfileController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Student.Authenticator

  alias Risen.Repo
  alias Risen.Student
  alias Risen.School
  alias Risen.Major

  plug :authenticate
  plug :require_student
  plug :load_school
  plug :load_majors
  plug :put_layout, "student.html"

  def edit(conn, _params) do
    student = conn.assigns[:student]
    changeset = Ecto.Changeset.change(student)

    conn
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, params) do
    student = conn.assigns[:student]
    student_params = params["student"]

    student_changeset = Student.changeset(student, student_params)
    student = Repo.update!(student_changeset)

    Enum.each([{StudentPic, "pic"}, {StudentResume, "resume"}], fn({ m, p }) ->
      if params[p] do
        m.store({params[p], student})
        student_changeset = Student.changeset(student, %{ p => params[p].filename })
        Repo.update!(student_changeset)
      end
    end)

    conn
    |> put_flash(:success, "Profile saved successfully.")
    |> redirect(to: student_profile_path(conn, :edit, student.id))
  end

  defp load_school(conn, _) do
    school = Repo.get(School, conn.assigns[:student].school_id)
    conn |> assign(:school, school)
  end

  defp load_majors(conn, _) do
    majors = Repo.all(Major)
    conn |> assign(:majors, majors)
  end
end

defmodule Risen.Student.ProfileController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Student.Authenticator

  alias Risen.Repo
  alias Risen.Student
  alias Risen.School

  plug :authenticate
  plug :require_student
  plug :load_majors
  plug :put_layout, "student.html"

  def edit(conn, _params) do
    student = conn.assigns[:student]
    school = Repo.preload(student, :school).school
    changeset = Ecto.Changeset.change(student)

    conn
    |> assign(:changeset, changeset)
    |> assign(:school, school)
    |> assign(:edit, true)
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
        student = Repo.update!(student_changeset)
      end
    end)

    conn
    |> put_flash(:info, "Student saved successfully.")
    |> redirect(to: student_profile_path(conn, :edit, student.id))
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

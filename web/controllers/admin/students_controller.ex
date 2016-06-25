defmodule Risen.Admin.StudentsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.Student
  alias Risen.School
  alias Risen.Major
  alias Risen.StudentService
  alias Risen.BatchService

  plug :authenticate
  plug :require_admin
  plug :load_student when action in [:edit, :update]
  plug :load_school when action in [:edit, :update]
  plug :load_majors when action in [:edit, :update]
  plug :load_student_batches when action in [:edit, :update]
  plug :put_layout, "admin.html"

  def index(conn, _params) do
    pending_students = (
      StudentService.students_with_status("Pending")
      |> Repo.preload([:school, :major])
    )
    upcoming_batch = (
      BatchService.upcoming_batch()
      |> Repo.preload([students: [:school, :major]])
    )
    sent_batches = (
      BatchService.sent_batches()
      |> Repo.preload([students: [:school, :major]])
    )
    conn
    |> assign(:pending_students, pending_students)
    |> assign(:upcoming_batch, upcoming_batch)
    |> assign(:sent_batches, sent_batches)
    |> render("index.html")
  end

  def edit(conn, _params) do
    student = conn.assigns[:student]
    changeset = Ecto.Changeset.change(student)

    conn
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, params) do
    student = conn.assigns[:student]

    if params["mark_ready"] do
      student |> StudentService.mark_ready()
    else
      Repo.update!(
        Student.changeset(
          student,
          params["student"]
        )
      )
      |> StudentService.upload_pic(params["pic"])
      |> StudentService.upload_resume(params["resume"])
    end

    conn
    |> put_flash(:info, "Student saved successfully.")
    |> redirect(to: admin_students_path(conn, :edit, student.id))
  end

  defp load_student(conn, _) do
    student = Repo.get(Student, conn.params["id"])
    student = Repo.preload(student, [:major, :school])
    conn |> assign(:student, student)
  end

  defp load_school(conn, _) do
    school = Repo.get(School, conn.assigns[:student].school_id)
    conn |> assign(:school, school)
  end

  defp load_majors(conn, _) do
    majors = Repo.all(Major)
    conn |> assign(:majors, majors)
  end

  defp load_student_batches(conn, _) do
    student = conn.assigns[:student]
    if student.status == "Ready" do
      conn |> assign(
        :student_batches,
        StudentService.batches_assigned(student)
      )
    else
      conn
    end
  end
end

defmodule Risen.Admin.StudentsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.Student
  alias Risen.Batch

  plug :authenticate
  plug :require_admin
  plug :load_student when action in [:edit, :update]
  plug :put_layout, "admin.html"

  def index(conn, _params) do

    # Grab all the pending students. We'll show these first,
    # before the sent batches
    pending_students = Repo.all(
      from s in Student,
      where: s.status == "Pending",
      preload: [:school, :major]
    )

    # Grab upcoming batch
    upcoming_batch = Repo.one(
      from b in Batch,
      where: is_nil(b.sent_at),
      preload: [students: [:school, :major]]
    )

    # Grab all sent batches
    sent_batches = Repo.all(
      from b in Batch,
      where: not(is_nil(b.sent_at)),
      preload: [students: [:school, :major]]
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

  defp load_student(conn, _) do
    student = Repo.get(Student, conn.params["id"])
    conn |> assign(:student, student)
  end
end

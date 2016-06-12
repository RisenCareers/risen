defmodule Risen.Employer.StudentsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Employer.Authenticator

  alias Risen.Repo
  alias Risen.Batch
  alias Risen.Student
  alias Risen.EmployerStudentInterest
  alias Risen.EmployerService

  plug :put_layout, "employer.html"
  plug :authenticate
  plug :require_employer
  plug :require_employer_admin
  plug :load_employer_majors
  plug :load_student when action in [:show, :update]
  plug :employer_interested? when action in [:show, :update]

  # Look through all BatchStudents (via all SENT batches) and see
  # if any majors align with this Employer's interests. If they do,
  # show them here.
  #
  # This means batches are living - they change based on the employer's
  # interests changing. If we did not want to do this, it gets quite a bit
  # more complicated in the batch logic.
  def index(conn, params) do

    # Retrieve employer via the Authenticator plug
    employer = conn.assigns[:employer]

    # This subquery grabs only students of the employer interested majors
    student_query = from s in Student,
      where: s.major_id in ^(Enum.map(employer.majors, &(&1.id))),
      preload: [:major, :school]

    # Grab all sent batches along with relevant students
    filters = []
    filters = filters ++ cond do
      params["batch"] -> [id: String.to_integer(params["batch"])]
      true -> []
    end
    batches = Repo.all(
      from b in Batch,
      where: ^filters,
      where: not(is_nil(b.sent_at)),
      preload: [students: ^student_query]
    )

    conn
    |> assign(:batches, batches)
    |> render("index.html")
  end

  def show(conn, _params) do
    conn |> render("show.html")
  end

  def update(conn, params) do
    employer = conn.assigns[:employer]
    student = conn.assigns[:student]
    employer_interested = conn.assigns[:employer_interested]

    if params["interested"] do
      unless employer_interested do
        Repo.insert!(%EmployerStudentInterest{
          employer_id: employer.id,
          student_id: student.id
        })
      end
    end

    conn
    |> redirect(to: employer_students_path(conn, :show, employer.slug, student.id))
    |> halt()
  end

  def employer_interested?(conn, _) do
    employer = conn.assigns[:employer]
    student = conn.assigns[:student]

    count = Repo.one(
      from i in EmployerStudentInterest,
      where: i.employer_id == ^employer.id and i.student_id == ^student.id,
      select: count(i.id)
    )

    conn |> assign(:employer_interested, count > 0)
  end

  def load_employer_majors(conn, _) do
    employer = conn.assigns[:employer]
    employer = EmployerService.load_current_majors(employer)
    conn |> assign(:employer, employer)
  end

  def load_student(conn, _) do
    employer = conn.assigns[:employer]
    student = Repo.get(Student, conn.params["id"])

    unless student do
      conn
      |> redirect(to: employer_batches_path(conn, :index, employer.slug))
      |> halt()
    else
      batch_ids = Enum.map(
        Repo.all(
          from bs in Risen.BatchStudent,
          where: bs.student_id == ^student.id
        ),
        &(&1.batch_id)
      )

      batches = Repo.all(
        from b in Risen.Batch,
        where: b.id in ^batch_ids
      )

      # Get majors from all relevant batches
      major_ids = EmployerService.major_ids_of_interest_for_batches(
        employer,
        batches
      )

      # Redirect back to students if the student does not have any majors that
      # the employer is interested in
      unless Enum.member?(major_ids, student.major_id) do
        conn
        |> redirect(to: employer_batches_path(conn, :index, employer.slug))
        |> halt()
      else
        student = Repo.preload(student, [:account, :school, :major])
        conn |> assign(:student, student)
      end
    end

  end

end

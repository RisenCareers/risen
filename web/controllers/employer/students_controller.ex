defmodule Risen.Employer.StudentsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Employer.Authenticator

  alias Risen.Repo
  alias Risen.Batch
  alias Risen.BatchStudent
  alias Risen.Student

  plug :put_layout, "employer.html"
  plug :authenticate
  plug :require_employer
  plug :require_employer_admin

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
    employer = Repo.preload(employer, [:majors])

    # This subquery grabs only students of the employer interested majors
    student_query = from s in Student,
      where: s.major_id in ^(Enum.map(employer.majors, fn m -> m.id end)),
      preload: [:major, :school]

    # Grab all sent batches along with relevant students
    batches = Repo.all(
      from b in Batch,
      where: not(is_nil(b.sent_at)),
      preload: [students: ^student_query]
    )

    render conn, "index.html", batches: batches
  end

  def show(conn, params) do
    # Retrieve employer via the Authenticator plug
    employer = conn.assigns[:employer]
    employer = Repo.preload(employer, [:majors])

    # Retrieve the current student from the path
    student = Repo.get(Student, params["id"])
    student = Repo.preload(student, [:school, :major])

    # Redirect back to students if the student does not exist
    # or if the student does not have any majors that the employer
    # is interested in
    unless student && Enum.member?(employer.majors, student.major) do
      conn
      |> redirect(to: employer_students_path(conn, :index, employer.slug))
      |> halt()
    else
      conn
      |> assign(:student, student)
      |> render "show.html"
    end
  end

end

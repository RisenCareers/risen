defmodule Risen.Employer.BatchesController do
  use Risen.Web, :controller
  use Timex

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Employer.Authenticator

  alias Risen.Repo
  alias Risen.Batch
  alias Risen.Student
  alias Risen.BatchStudent
  alias Risen.EmployerService
  alias Risen.EmployerMajor
  alias Risen.Major

  plug :put_layout, "employer.html"
  plug :authenticate
  plug :require_employer
  plug :require_employer_admin
  # plug :load_employer_majors

  def index(conn, params) do
    employer = conn.assigns[:employer]

    # Get all batches sent after employer was inserted
    batches = Repo.all(
      from b in Batch,
      where: not(is_nil(b.sent_at)),
      where: b.sent_at > ^employer.inserted_at
    )

    conn
    |> assign(:batches, batches)
    |> render("index.html")
  end

  # Load all the students for this batch that are applicable
  # to the employer based on the time the batch was sent
  def show(conn, params) do
    employer = conn.assigns[:employer]

    batch = Repo.one(
      from b in Batch,
      where: b.id == ^params["id"],
      preload: [:students]
    )

    students = Repo.all(
      from s in Student,
      where: s.id in ^(Enum.map(batch.students, &(&1.id))),
      where: s.major_id in ^(
        EmployerService.major_ids_of_interest_for_batch(employer, batch)
      ),
      preload: [:school, :major]
    )

    conn
    |> assign(:batch, batch)
    |> assign(:students, students)
    |> render("show.html")
  end

  def load_employer_majors(conn, _) do
    employer = conn.assigns[:employer]
    employer = EmployerService.load_current_majors(employer)
    conn |> assign(:employer, employer)
  end

end

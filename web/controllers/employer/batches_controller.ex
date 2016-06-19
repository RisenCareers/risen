defmodule Risen.Employer.BatchesController do
  use Risen.Web, :controller
  use Timex

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Employer.Authenticator

  alias Risen.Repo
  alias Risen.Batch
  alias Risen.BatchService

  plug :put_layout, "employer.html"
  plug :authenticate
  plug :require_employer
  plug :require_employer_admin

  def index(conn, params) do
    employer = conn.assigns[:employer]
    batches = BatchService.all_batches_for_employer(employer)

    conn
    |> assign(:batches, batches)
    |> render("index.html")
  end

  # Load all the students for this batch that are applicable
  # to the employer based on the time the batch was sent
  def show(conn, params) do
    employer = conn.assigns[:employer]
    batch = Repo.get(Batch, params["id"])
    students = BatchService.students_for_batch_and_employer(batch, employer)

    conn
    |> assign(:batch, batch)
    |> assign(:students, students)
    |> render("show.html")
  end

end

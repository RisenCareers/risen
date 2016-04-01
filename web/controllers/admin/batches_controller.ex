defmodule Risen.Admin.BatchesController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.Batch
  alias Risen.Student
  alias Risen.Employer
  alias Risen.EmployerMajor

  plug :authenticate
  plug :require_admin
  plug :put_layout, "admin.html"

  def index(conn, _params) do
    # Grab upcoming batch
    upcoming_batch = Repo.one(
      from b in Batch,
      where: is_nil(b.sent_at),
      preload: [:students]
    )

    # Grab all sent batches
    sent_batches = Repo.all(
      from b in Batch,
      where: not(is_nil(b.sent_at)),
      preload: [:students]
    )

    conn
    |> assign(:upcoming_batch, upcoming_batch)
    |> assign(:sent_batches, sent_batches)
    |> render("index.html")
  end

  def show(conn, params) do

    batch = Repo.get(Batch, params["id"])
    batch = Repo.preload(batch, [students: [:major, :school]])
    majors = Enum.map(batch.students, fn(s) -> s.major end)

    # Get all employer majors based on the majors of the students
    employer_majors = Repo.all(
      from em in EmployerMajor,
      where: em.major_id in ^(Enum.map(majors, &(&1.id)))
    )

    # Get all employers
    employers = Repo.all(
      from e in Employer,
      where: e.id in ^(Enum.map(employer_majors, &(&1.employer_id))),
      preload: [:majors]
    )

    is_upcoming? = (batch.sent_at == nil)

    conn
    |> assign(:batch, batch)
    |> assign(:is_upcoming?, is_upcoming?)
    |> assign(:students, batch.students)
    |> assign(:employers, employers)
    |> render("show.html")
  end
end

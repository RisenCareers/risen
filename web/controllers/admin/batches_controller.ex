defmodule Risen.Admin.BatchesController do
  use Risen.Web, :controller
  use Timex

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.Major
  alias Risen.Batch
  alias Risen.Employer
  alias Risen.EmployerMajor
  alias Risen.EmployerService

  plug :authenticate
  plug :require_admin
  plug :load_batch when action in [:show, :update]
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

  def show(conn, _params) do
    batch = conn.assigns[:batch]
    majors = Enum.map(batch.students, fn(s) -> s.major end)

    # Get all employer majors based on the majors of the students
    query_time = if batch.sent_at, do: batch.sent_at, else: DateTime.now
    employer_majors = Repo.all(
      from em in EmployerMajor,
      where: em.major_id in ^(Enum.map(majors, &(&1.id))),
      where: ^query_time > em.inserted_at,
      where: (
        is_nil(em.removed_at)
        or (
          not(is_nil(em.removed_at))
          and ^query_time < em.removed_at
        )
      ),
      preload: [:major, :employer]
    )

    employers = Enum.uniq(Enum.map(employer_majors, &(&1.employer)), &(&1.id))

    is_upcoming = (batch.sent_at == nil)

    conn
    |> assign(:batch, batch)
    |> assign(:is_upcoming, is_upcoming)
    |> assign(:students, batch.students)
    |> assign(:employers, employers)
    |> assign(:employer_majors, employer_majors)
    |> render("show.html")
  end

  def update(conn, params) do
    batch = conn.assigns[:batch]

    if params["send"] do
      unless batch.sent_at do
        Repo.transaction fn ->
          batch_changeset = Ecto.Changeset.change(
            batch,
            sent_at: DateTime.set(DateTime.now, [millisecond: 0])
          )
          Repo.update!(batch_changeset)
          Repo.insert!(%Batch{})
        end
      end
    end

    conn
    |> redirect(to: admin_batches_path(conn, :show, batch.id))
    |> halt()
  end

  defp load_batch(conn, _) do
    batch = Repo.get(Batch, conn.params["id"])
    batch = Repo.preload(batch, [students: [:major, :school]])
    conn |> assign(:batch, batch)
  end
end

defmodule Risen.Admin.BatchesController do
  use Risen.Web, :controller
  use Timex

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.Batch
  alias Risen.EmployerService
  alias Risen.BatchService

  plug :authenticate
  plug :require_admin
  plug :load_batch when action in [:show, :update]
  plug :put_layout, "admin.html"

  def index(conn, _params) do
    upcoming_batch = (
      BatchService.upcoming_batch()
      |> Repo.preload([:students])
    )
    sent_batches = (
      BatchService.sent_batches()
      |> Repo.preload([:students])
    )
    conn
    |> assign(:upcoming_batch, upcoming_batch)
    |> assign(:sent_batches, sent_batches)
    |> render("index.html")
  end

  def show(conn, _params) do
    batch = conn.assigns[:batch]
    employer_majors = (
      EmployerService.employer_majors_for_batch(batch)
      |> Repo.preload([:major, :employer])
    )
    employers = Enum.uniq(
      Enum.map(
        employer_majors,
        &(&1.employer)
      ),
      &(&1.id)
    )
    conn
    |> assign(:batch, batch)
    |> assign(:is_upcoming, (batch.sent_at == nil))
    |> assign(:students, batch.students)
    |> assign(:employers, employers)
    |> assign(:employer_majors, employer_majors)
    |> render("show.html")
  end

  def update(conn, params) do
    batch = conn.assigns[:batch]
    if params["send"] do
      BatchService.send_batch(batch)
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

defmodule Risen.Admin.StudentsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.Student
  alias Risen.Batch

  plug :authenticate
  plug :require_admin
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

  def edit_get(conn, _params) do
    render conn, "edit.html"
  end

  def edit_patch(conn, _params) do
    render conn, "edit.html"
  end
end

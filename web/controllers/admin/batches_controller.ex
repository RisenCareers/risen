defmodule Risen.Admin.BatchesController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.Batch
  alias Risen.Student

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

  def show(conn, _params) do
    render conn, "show.html"
  end
end

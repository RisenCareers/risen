defmodule Risen.Admin.EmployersController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Admin.Authenticator

  alias Risen.Repo
  alias Risen.Employer
  alias Risen.Student

  plug :authenticate
  plug :require_admin
  plug :put_layout, "admin.html"

  def index(conn, _params) do
    employers = Repo.all(
      from e in Employer,
      preload: [:students]
    )

    conn
    |> assign(:employers, employers)
    |> render("index.html")
  end
end

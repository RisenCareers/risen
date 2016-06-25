defmodule Risen.Landing.SchoolsController do
  use Risen.Web, :controller

  alias Risen.Repo
  alias Risen.School

  plug :put_layout, "landing.html"

  def index(conn, _params) do
    schools = Repo.all(School)
    conn
    |> assign(:schools, schools)
    |> render("index.html")
  end
end

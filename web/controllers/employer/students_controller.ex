defmodule Risen.Employer.StudentsController do
  use Risen.Web, :controller

  plug :put_layout, "employer.html"

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, _params) do
    render conn, "show.html"
  end
end

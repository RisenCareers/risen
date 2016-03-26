defmodule Risen.Employer.StudentsController do
  use Risen.Web, :controller

  plug :put_layout, "employer.html"
  plug Risen.Employer.Plugs.Authenticator

  def index(conn, params) do
    render conn, "index.html"
  end

  def show(conn, _params) do
    render conn, "show.html"
  end

end

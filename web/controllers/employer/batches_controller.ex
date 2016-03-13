defmodule Risen.Employer.BatchesController do
  use Risen.Web, :controller

  plug :put_layout, "employer.html"

  def show(conn, _params) do
    render conn, "show.html"
  end
end

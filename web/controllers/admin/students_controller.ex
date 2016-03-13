defmodule Risen.Admin.StudentsController do
  use Risen.Web, :controller

  plug :put_layout, "admin.html"

  def index(conn, _params) do
    render conn, "index.html"
  end

  def edit_get(conn, _params) do
    render conn, "edit.html"
  end

  def edit_patch(conn, _params) do
    render conn, "edit.html"
  end
end

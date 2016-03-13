defmodule Risen.Student.ProfileController do
  use Risen.Web, :controller

  plug :put_layout, "student.html"

  def edit_get(conn, _params) do
    render conn, "edit.html"
  end

  def edit_patch(conn, _params) do
    render conn, "edit.html"
  end
end

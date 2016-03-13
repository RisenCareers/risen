defmodule Risen.Student.RegisterController do
  use Risen.Web, :controller

  plug :put_layout, "student.html"

  def register_get(conn, _params) do
    render conn, "register.html"
  end

  def register_post(conn, _params) do
    render conn, "register.html"
  end

  def profile_get(conn, _params) do
    render conn, "profile.html"
  end

  def profile_post(conn, _params) do
    render conn, "profile.html"
  end
end

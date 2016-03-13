defmodule Risen.Employer.RegisterController do
  use Risen.Web, :controller

  plug :put_layout, "employer.html"

  def register_get(conn, _params) do
    render conn, "register.html"
  end

  def register_post(conn, _params) do
    render conn, "register.html"
  end

  def setup_get(conn, _params) do
    render conn, "setup.html"
  end

  def setup_post(conn, _params) do
    render conn, "setup.html"
  end
end

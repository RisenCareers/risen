defmodule Risen.Employer.SettingsController do
  use Risen.Web, :controller

  plug :put_layout, "employer.html"

  def show(conn, _params) do
    render conn, "show.html"
  end

  def update(conn, _params) do
    render conn, "show.html"
  end
end

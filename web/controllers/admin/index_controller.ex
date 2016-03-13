defmodule Risen.Admin.IndexController do
  use Risen.Web, :controller

  def index(conn, _params) do
    redirect conn, to: admin_students_path(conn, :admin_students)
  end
end

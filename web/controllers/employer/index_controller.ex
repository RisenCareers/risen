defmodule Risen.Employer.IndexController do
  use Risen.Web, :controller

  def index(conn, _params) do
    redirect conn, to: employer_register_path(conn, :register_get)
  end
end

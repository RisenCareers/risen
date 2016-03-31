defmodule Risen.Employer.IndexController do
  use Risen.Web, :controller

  def index(conn, _params) do
    redirect conn, to: employer_register_path(conn, :new)
  end
end

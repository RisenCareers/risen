defmodule Risen.Admin.IndexController do
  use Risen.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

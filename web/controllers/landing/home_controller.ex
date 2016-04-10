defmodule Risen.Landing.HomeController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator

  plug :put_layout, "landing.html"
  plug :check_authentication

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end

defmodule Risen.Landing.AccountController do
  use Risen.Web, :controller

  plug :put_layout, "landing.html"

  def signin_get(conn, _params) do
    render conn, "signin.html"
  end

  def signin_post(conn, _params) do
    render conn, "signin.html"
  end
end

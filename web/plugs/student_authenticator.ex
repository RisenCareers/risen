defmodule Risen.Plugs.Student.Authenticator do
  import Plug.Conn
  import Risen.Router.Helpers
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias Risen.Repo
  alias Risen.Student

  def require_student(conn, _) do
    student = Repo.get(Student, conn.params["id"])
    student = Repo.preload(student, [:major])
    unless student do
      conn |> inauthenticated
    else
      unless student.account_id == conn.assigns[:account].id do
        conn |> inauthenticated
      else
        conn |> assign(:student, student)
      end
    end
  end

  defp inauthenticated(conn) do
    conn
    |> put_flash(:info, "Not authorized")
    |> redirect(to: home_path(conn, :index))
    |> halt()
  end

end

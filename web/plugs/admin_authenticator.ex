defmodule Risen.Plugs.Admin.Authenticator do
  import Plug.Conn
  import Risen.Router.Helpers
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def require_admin(conn, _) do
    roles = Enum.map(conn.assigns[:account].roles, &(&1.name))
    cond do
      Enum.member?(roles, "RisenAdmin") -> conn
      true -> conn |> inauthenticated
    end
  end

  defp inauthenticated(conn) do
    conn
    |> put_flash(:info, "Not authorized")
    |> redirect(to: home_path(conn, :index))
    |> halt()
  end

end

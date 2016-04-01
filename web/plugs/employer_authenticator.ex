defmodule Risen.Plugs.Employer.Authenticator do
  import Plug.Conn
  import Risen.Router.Helpers
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias Risen.Repo
  alias Risen.Employer

  def require_employer(conn, _) do
    employer = Repo.get_by(Employer, slug: conn.params["employer_slug"])
    unless employer do
      conn |> inauthenticated
    else
      employer = Repo.preload(employer, [:admins])
      conn |> assign(:employer, employer)
    end
  end

  def require_employer_admin(conn, _) do
    admin_ids = Enum.map(conn.assigns[:employer].admins, &(&1.id))
    unless Enum.member?(admin_ids, conn.assigns[:account].id) do
      conn |> inauthenticated
    else
      conn
    end
  end

  defp inauthenticated(conn) do
    conn
    |> put_flash(:info, "You must be a registered employer")
    |> redirect(to: employer_register_path(conn, :new))
    |> halt()
  end

end

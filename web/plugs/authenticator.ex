defmodule Risen.Plugs.Authenticator do
  import Plug.Conn
  import Risen.Router.Helpers
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias Risen.Repo
  alias Risen.Account

  def authenticate(conn, _) do
    account_id = get_session(conn, :account_id)
    unless account_id do
      conn |> inauthenticated
    else
      account = Repo.get(Account, account_id)
      account = Repo.preload(account, [:roles])
      unless account do
        conn |> inauthenticated
      else
        conn |> assign(:account, account)
      end
    end
  end

  defp inauthenticated(conn) do
    conn
    |> put_flash(:info, "You must be logged in")
    |> redirect(to: account_path(conn, :signin_get))
    |> halt()
  end

end

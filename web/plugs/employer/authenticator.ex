defmodule Risen.Employer.Plugs.Authenticator do
  import Plug.Conn
  import Risen.Router.Helpers

  alias Risen.Repo
  alias Risen.Account
  alias Risen.Employer

  def init(default), do: default

  def call(conn, _) do

    # Get the account tied to the session
    account_id = get_session(conn, :account_id)

    unless account_id, do: conn |> inauthenticated

    # Retrieve the employer based on the URL, preloading admins
    employer = Repo.get_by(Employer, slug: conn.params["employer_slug"])

    unless employer, do: conn |> inauthenticated

    # Retrieve the account in the session
    account = Repo.get(Account, account_id)

    # Preload the employer admins
    employer = Repo.preload(employer, [:admins])

    # Check if account is an employer admin
    unless Enum.member?(employer.admins, account), do: conn |> inauthenticated

    conn
    |> assign(:account, account)
    |> assign(:employer, employer)

  end

  defp inauthenticated(conn) do
    conn
    |> Phoenix.Controller.redirect(to: employer_register_path(conn, :register_get))
    |> halt()
  end

end

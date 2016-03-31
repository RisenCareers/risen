defmodule Risen.Landing.AccountController do
  use Risen.Web, :controller

  import ROP
  import Comeonin.Bcrypt

  alias Risen.Repo
  alias Risen.Account

  plug :put_layout, "landing.html"

  def signin_get(conn, _params) do
    render conn, "signin.html", errors: []
  end

  def signin_post(conn, _params) do
    conn
    |>  load_account
    >>> check_credentials
    >>> (bind load_roles)
    |> case do
      {:ok, conn} ->
        account = conn.assigns[:account]
        cond do
          Account.has_role?(account, "RisenAdmin") ->
            conn |> good_credentials(account, admin_index_path(conn, :index))
          Account.has_role?(account, "EmployerAdmin") ->
            account = Repo.preload(account, [:employers])
            conn |> good_credentials(account, employer_students_path(conn, :index, hd(account.employers).slug))
          Account.has_role?(account, "Student") ->
            conn |> good_credentials(account, home_path(conn, :index))
        end
      {:error, m} -> conn |> bad_credentials([account: m])
    end
  end

  # Sign out a user by simply accessing this URL
  def signout_get(conn, _params) do
    conn
    |> clear_session
    |> redirect(to: home_path(conn, :index))
    |> halt()
  end

  defp load_account(conn) do
    # Get the account by email (lowercase for sanity)
    email = String.downcase(conn.params["email"])
    account = Repo.get_by(Account, email: email)

    # Check for valid account and password
    unless account do
      {:error, "No account with that email."}
    else
      {:ok, conn |> assign(:account, account)}
    end
  end

  defp check_credentials(conn) do
    unless checkpw(conn.params["password"], conn.assigns[:account].password_hash) do
      {:error, "Invalid credentials."}
    else
      {:ok, conn}
    end
  end

  defp load_roles(conn) do
    account = conn.assigns[:account]
    account = Repo.preload(account, [:roles])
    conn |> assign(:account, account)
  end

  defp good_credentials(conn, account, redirect_path) do
    conn
    |> assign(:errors, [])
    |> put_session(:account_id, account.id)
    |> redirect(to: redirect_path)
    |> halt()
  end

  defp bad_credentials(conn, errors) do
    conn
    |> render("signin.html", errors: errors)
    |> halt()
  end

end

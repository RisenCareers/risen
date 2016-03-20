defmodule Risen.Student.RegisterController do
  use Risen.Web, :controller

  alias Risen.Student
  alias Risen.Account
  alias Risen.Role

  plug :scrub_params, "user" when action in [:create, :update]
  plug :put_layout, "student.html"

  def account(conn, _params) do
    changeset = Account.changeset(%Account{})
    conn
    |> assign(:school, %{slug: "test"})
    |> render("account.html", changeset: changeset)
  end

  def account_create(conn, %{"account" => account_params}) do
    changeset = Account.changeset(%Account{}, account_params)
    conn = assign(conn, :school, %{slug: "test"})
    case Repo.insert(changeset) do
      {:ok, _account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: student_register_path(conn, :done, "test"))
      {:error, changeset} ->
        render(conn, "account.html", changeset: changeset)
    end
  end

  def setup(conn, _params) do
    render conn, "setup.html"
  end

  def setup_create(conn, _params) do
    render conn, "setup.html"
  end

  def done(conn, _params) do
    render conn, "done.html"
  end
end

defmodule Risen.Student.RegisterController do
  use Risen.Web, :controller

  alias Risen.Student
  alias Risen.Account
  alias Risen.Role
  alias Risen.School

  plug :load_school
  plug :scrub_params, "account" when action in [:create]
  plug :put_layout, "student.html"

  def new(conn, _params) do
    conn
    |> assign(:errors, [])
    |> render("new.html")
  end

  def create(conn, params) do
    school = conn.assigns[:school]

    # Wrap the creation of things in a transaction.
    # If one fails, WE ALL FAIL
    tx_result = Repo.transaction fn ->
      account_changeset = Account.changeset(%Account{}, params["account"])
      case Repo.insert(account_changeset) do
        {:ok, account} ->
          role = Repo.get_by(Role, name: "Student")
          account_role = %Risen.AccountRole{
            account_id: account.id,
            role_id: role.id
          }
          case Repo.insert(account_role) do
            {:ok, _new_account_role} ->
              student_params = %{
                name: params["student"]["name"],
                account_id: account.id,
                school_id: school.id,
                status: "Pending"
              }
              student_changeset = Student.changeset(%Student{}, student_params)
              case Repo.insert(student_changeset) do
                {:ok, student} ->
                  Risen.Mailer.send_student_welcome_email(student)
                  conn
                  |> put_session(:account_id, account.id)
                  |> redirect(
                    to: student_setup_path(conn, :edit, school.slug, student.id)
                  )
                {:error, changeset} ->
                  errors = Ecto.Changeset.traverse_errors(
                    changeset,
                    &Risen.ErrorHelpers.translate_error/1
                  )
                  conn
                  |> assign(:errors, errors)
                  |> render("new.html")
                  |> Repo.rollback
              end
            {:error, changeset} ->
              errors = Ecto.Changeset.traverse_errors(
                changeset,
                &Risen.ErrorHelpers.translate_error/1
              )
              conn
              |> assign(:errors, errors)
              |> render("new.html")
              |> Repo.rollback
          end
        {:error, changeset} ->
          errors = Ecto.Changeset.traverse_errors(
            changeset,
            &Risen.ErrorHelpers.translate_error/1
          )
          conn
          |> assign(:errors, errors)
          |> render("new.html")
          |> Repo.rollback
      end
    end

    elem(tx_result, 1)
  end

  defp load_school(conn, _) do
    school = Repo.get_by(School, slug: conn.params["school_slug"])
    conn
    |> assign(:school, school)
  end
end

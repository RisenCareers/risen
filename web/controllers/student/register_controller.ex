defmodule Risen.Student.RegisterController do
  use Risen.Web, :controller
  import Comeonin.Bcrypt

  alias Risen.Student
  alias Risen.Account
  alias Risen.Role
  alias Risen.School

  plug :scrub_params, "account" when action in [:create]
  plug :put_layout, "student.html"

  def new(conn, params) do
    school = Repo.get_by(School, slug: params["school_slug"])
    changeset = Account.changeset(%Account{})
    render(conn, "new.html", changeset: changeset, school: school)
  end

  def create(conn, params) do
    school = Repo.get_by(School, slug: params["school_slug"])
    conn = assign(conn, :school, %{slug: school.slug})

    # Hash the password for security
    hash = hashpwsalt(params["account"]["password"])

    # Create the changes for the account
    changeset = Account.changeset(
      %Account{},
      Map.merge(params["account"], %{ "password_hash" => hash })
    )

    case Repo.insert(changeset) do
      {:ok, account} ->

        # Add the Student role to the account
        role = Repo.get_by(Role, name: "Student")
        account_role = %Risen.AccountRole{
          account_id: account.id,
          role_id: role.id
        }

        case Repo.insert(account_role) do
          {:ok, _new_account_role} ->

            # Create the student
            student_params = %{
              name: params["account"]["name"],
              account_id: account.id,
              school_id: school.id
            }
            student_changeset = Student.changeset(%Student{}, student_params)

            case Repo.insert(student_changeset) do
              {:ok, student} ->
                conn
                |> put_session(:account_id, account.id)
                |> put_flash(:info, "Account created successfully.")
                |> redirect(to: student_setup_path(conn, :edit, school.slug, student.id))
              {:error, changeset} ->
                render(conn, "new.html", changeset: changeset)
            end

          {:error, changeset} ->
            render(conn, "new.html", changeset: changeset)

        end

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end

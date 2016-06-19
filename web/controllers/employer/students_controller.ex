defmodule Risen.Employer.StudentsController do
  use Risen.Web, :controller

  import Risen.Plugs.Authenticator
  import Risen.Plugs.Employer.Authenticator

  alias Risen.Repo
  alias Risen.Student
  alias Risen.EmployerService

  plug :put_layout, "employer.html"
  plug :authenticate
  plug :require_employer
  plug :require_employer_admin
  plug :load_employer_majors
  plug :load_student when action in [:show, :update]
  plug :employer_interested? when action in [:show, :update]

  def show(conn, _params) do
    conn |> render("show.html")
  end

  def update(conn, params) do
    employer = conn.assigns[:employer]
    student = conn.assigns[:student]
    employer_interested = conn.assigns[:employer_interested]

    if params["interested"] do
      EmployerService.mark_interested_in_student(employer, student)
    end

    conn
    |> redirect(to: employer_students_path(conn, :show, employer.slug, student.id))
    |> halt()
  end

  def employer_interested?(conn, _) do
    conn |> assign(
      :employer_interested,
      EmployerService.interested_in_student(
        conn.assigns[:employer],
        conn.assigns[:student]
      )
    )
  end

  def load_employer_majors(conn, _) do
    conn |> assign(
      :employer,
      EmployerService.load_current_majors(conn.assigns[:employer])
    )
  end

  def load_student(conn, _) do
    employer = conn.assigns[:employer]
    student = Repo.get(Student, conn.params["id"])
    unless student do
      conn
      |> redirect(to: employer_batches_path(conn, :index, employer.slug))
      |> halt()
    else
      # Redirect back to students if the student does not have any majors that
      # the employer is interested in
      unless EmployerService.can_view_student(employer, student) do
        conn
        |> redirect(to: employer_batches_path(conn, :index, employer.slug))
        |> halt()
      else
        student = Repo.preload(student, [:account, :school, :major])
        conn |> assign(:student, student)
      end
    end
  end

end

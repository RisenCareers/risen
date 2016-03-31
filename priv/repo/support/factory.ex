defmodule Risen.Factory do
  use Timex

  import Comeonin.Bcrypt

  alias Risen.Repo
  alias Risen.Account
  alias Risen.AccountRole
  alias Risen.Role
  alias Risen.Major
  alias Risen.School
  alias Risen.Student

  def build_school(opts = %{}) do
    Repo.insert!(
      Map.merge(
        %School{
          name: "Bob Jones University",
          abbreviation: "BJU",
          slug: "bju"
        },
        opts
      )
    )
  end

  def build_student(opts = %{}) do
    r = Repo.get_by(Role, name: "Student")
    m = cond do
      opts[:major] -> Repo.get_by(Major, name: opts[:major])
      true -> Enum.random(Repo.all(Major))
    end

    s = cond do
      opts[:school] -> Repo.get_by(School, slug: opts[:school])
      true -> Enum.random(Repo.all(School))
    end

    a = Repo.insert!(
      Map.merge(
        %Account{
          email: "student.01@example",
          password_hash: hashpwsalt("testing")
        },
        opts[:account] || %{}
      )
    )
    Repo.insert!(%AccountRole{ role_id: r.id, account_id: a.id })

    s = Repo.insert!(
      Map.merge(
        %Student{
          account_id: a.id,
          school_id: s.id,
          major_id: m.id,
          name: _name,
          phone: "(555) 555-5555",
          ideal_role: "Developer",
          visa_status: List.first(Student.visa_statuses),
          job_type: List.first(Student.job_types),
          location_preference: "New York, NY; Remote",
          status: Enum.random(["Pending", "Ready"])
        },
        opts[:student] || %{}
      )
    )

    s
  end

  def _first_names() do
    [
      "Vicky",
      "Jesse",
      "Stephen",
      "John",
      "Jane",
      "Jimi",
      "Susan",
      "Geoffrey",
      "Sam",
    ]
  end

  def _last_names() do
    [
      "Leong",
      "Tomlinson",
      "Watkins",
      "Smith",
      "Doe",
      "Hendrix",
      "Anthony",
      "Herald",
      "Jackson"
    ]
  end

  def _name() do
    "#{Enum.random(_first_names)} #{Enum.random(_last_names)}"
  end
end

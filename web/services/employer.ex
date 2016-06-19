defmodule Risen.EmployerService do
  import Ecto.Query, only: [from: 1, from: 2]
  use Timex

  alias Ecto.Changeset

  alias Risen.Repo
  alias Risen.Role
  alias Risen.AccountRole
  alias Risen.Major
  alias Risen.Batch
  alias Risen.BatchStudent
  alias Risen.EmployerLogo
  alias Risen.Employer
  alias Risen.EmployerMajor
  alias Risen.EmployerStudentInterest

  # Saves an employer settings based on the passed connection object. Will also
  # run the success callback
  def save_settings(conn, employer, view, on_success) do
    changeset = Employer.changeset(employer)
    tx_result = Repo.transaction fn ->
      case upload_logo(conn, conn.params["logo"]) do
        {:ok, employer} ->
          case save_majors(conn, conn.params["employer"]["majors"]) do
            {:ok, employer} ->
              conn |> on_success.()
            {:error, _} ->
              changeset = Changeset.add_error(changeset, :logo, "errored uploading")
              conn
              |> conn.assign(:changeset, changeset)
              |> conn.render(view)
              |> Repo.rollback
          end
        {:error, _} ->
          changeset = Changeset.add_error(changeset, :logo, "errored uploading")
          conn
          |> conn.assign(:changeset, changeset)
          |> conn.render(view)
          |> Repo.rollback
      end
    end
    elem(tx_result, 1)
  end

  def can_view_student(employer, student) do
    batch_ids = Enum.map(
      Repo.all(
        from bs in BatchStudent,
        where: bs.student_id == ^student.id
      ),
      &(&1.batch_id)
    )

    batches = Repo.all(
      from b in Batch,
      where: b.id in ^batch_ids
    )

    # Get majors from all relevant batches
    major_ids = major_ids_of_interest_for_batches(
      employer,
      batches
    )

    Enum.member?(major_ids, student.major_id)
  end

  # Return whether or not the employer has marked that they are interested
  # in this student
  def interested_in_student(employer, student) do
    Repo.one(
      from esi in EmployerStudentInterest,
      where: esi.employer_id == ^employer.id and esi.student_id == ^student.id,
      select: count(esi.id)
    ) > 0
  end

  # Marks the student interested by this employer, as long as they aren't
  # already interested
  def mark_interested_in_student(employer, student) do
    unless interested_in_student(employer, student) do
      Repo.insert!(
        %EmployerStudentInterest{
          employer_id: employer.id,
          student_id: student.id
        }
      )
    end
  end

  # Return all major IDs that were of interest when the specified batch was
  # sent. If batch was sent after a major was added but before it was removed
  # or if it was not removed
  def major_ids_of_interest_for_batch(employer, batch) do
    majors_of_interest_when_sent = Repo.all(
      from em in EmployerMajor,
      where: em.employer_id == ^employer.id,
      where: ^batch.sent_at > em.inserted_at,
      where: (
        is_nil(em.removed_at)
        or (
          not(is_nil(em.removed_at))
          and ^batch.sent_at < em.removed_at
        )
      )
    )
    Enum.map(majors_of_interest_when_sent, &(&1.major_id))
  end

  def major_ids_of_interest_for_batches(employer, batches) do
    Enum.reduce(batches, [], fn(batch, acc) ->
      acc ++ major_ids_of_interest_for_batch(employer, batch)
    end)
  end

  def create_admin(model) do
    admin = Repo.insert!(model)
    role = Repo.get_by(Role, name: "EmployerAdmin")
    Repo.insert!(%AccountRole{
      account_id: admin.account_id,
      role_id: role.id
    })
    admin
  end

  def upload_logo(conn, logo_param) do
    employer = conn.assigns[:employer]
    if logo_param do
      case EmployerLogo.store({logo_param, employer}) do
        {:ok, _} ->
          employer_changeset = Employer.changeset(employer, %{
            "logo" => logo_param.filename
          })
          Repo.update(employer_changeset)
        {:error, error} -> {:error, error}
      end
    else
      {:ok, employer}
    end
  end

  def load_current_majors(employer) do
    curr_employer_majors = Repo.all(
      from(
        em in EmployerMajor,
        where: em.employer_id == ^employer.id,
        where: em.is_current == true
      )
    )
    employer_major_major_ids = Enum.map(curr_employer_majors, &(&1.major_id))
    Repo.preload(
      employer,
      majors: from(
        m in Major,
        where: m.id in ^employer_major_major_ids
      )
    )
  end

  def save_majors(conn, majors_param) do
    employer = conn.assigns[:employer]

    # Update the employer interests
    if majors_param do
      tx_result = Repo.transaction fn ->
        # Expire all current majors
        Ecto.Query.from(
          em in EmployerMajor,
          where: em.employer_id == ^employer.id
        )
        |> Repo.update_all(set: [
          is_current: false,
          removed_at: DateTime.set(DateTime.now, [millisecond: 0])
        ])

        # Insert the new majors
        Enum.each(majors_param, fn m ->
          Repo.insert!(%EmployerMajor{
            major_id: String.to_integer(m),
            employer_id: employer.id
          })
        end)

        employer
      end
      tx_result
    else
      {:ok, employer}
    end

  end
end

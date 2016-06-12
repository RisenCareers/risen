defmodule Risen.EmployerService do
  import Ecto.Query, only: [from: 1, from: 2]
  use Timex

  alias Risen.Repo
  alias Risen.Role
  alias Risen.AccountRole
  alias Risen.EmployerLogo
  alias Risen.Employer
  alias Risen.EmployerMajor
  alias Risen.Major

  def major_ids_of_interest_for_batch(employer, batch) do
    # If batch was sent after a major was added but before it was removed
    # or if it was not removed
    majors_of_interest_when_sent = Repo.all(
      from em in Risen.EmployerMajor,
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

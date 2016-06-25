defmodule Risen.BatchService do
  import Ecto.Query, only: [from: 1, from: 2]
  use Timex

  alias Risen.Repo
  alias Risen.Batch
  alias Risen.Student
  alias Risen.EmployerService

  def upcoming_batch() do
    Repo.one(
      from b in Batch,
      where: is_nil(b.sent_at)
    )
  end

  def sent_batches() do
    Repo.all(
      from b in Batch,
      where: not(is_nil(b.sent_at))
    )
  end

  def send_batch(batch) do
    unless batch.sent_at do
      Repo.transaction fn ->
        Repo.update!(
          Ecto.Changeset.change(
            batch,
            sent_at: DateTime.set(DateTime.now, [millisecond: 0])
          )
        )
        Repo.insert!(%Batch{})
      end
    end
  end

  def all_batches_for_employer(employer) do
    Repo.all(
      from b in Batch,
      where: not(is_nil(b.sent_at)),
      where: b.sent_at > ^employer.inserted_at
    )
  end

  def students_for_batch_and_employer(batch, employer) do
    batch = Repo.preload(batch, [:students])
    Repo.all(
      from s in Student,
      where: s.id in ^(Enum.map(batch.students, &(&1.id))),
      where: s.major_id in ^(
        EmployerService.major_ids_of_interest_for_batch(employer, batch)
      ),
      preload: [:school, :major]
    )
  end

end

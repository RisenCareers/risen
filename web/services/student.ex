defmodule Risen.StudentService do
  import Ecto.Query, only: [from: 1, from: 2]
  use Timex

  alias Risen.Repo
  alias Risen.Student
  alias Risen.StudentPic
  alias Risen.StudentResume
  alias Risen.Batch
  alias Risen.BatchStudent

  # Get all students that are pending
  def students_with_status(student_status) do
    Repo.all(
      from s in Student,
      where: s.status == ^student_status
    )
  end

  def batches_assigned(student) do
    Repo.all(
      from b in Batch,
      where: b.id in ^(
        Enum.map(
          Repo.all(
            from bs in BatchStudent,
            where: bs.student_id == ^student.id
          ),
          &(&1.batch_id)
        )
      )
    )
  end

  def mark_ready(student) do
    unless student.status == "Ready" do
      Repo.transaction fn ->
        # Get the upcoming batch
        upcoming_batch = Repo.one(
          from b in Batch,
          where: is_nil(b.sent_at)
        )

        # Assign student to upcoming batch
        Repo.insert!(
          %BatchStudent{
            batch_id: upcoming_batch.id,
            student_id: student.id
          }
        )

        # Mark the student ready
        Repo.update!(
          Ecto.Changeset.change(
            student,
            status: "Ready"
          )
        )
      end
    end
  end

  def upload_pic(student, pic_param) do
    if pic_param do
      case StudentPic.store({pic_param, student}) do
        {:ok, _} ->
          Repo.update(
            Student.changeset(
              student,
              %{"pic" => pic_param.filename}
            )
          )
        {:error, error} -> {:error, error}
      end
    else
      {:ok, student}
    end
  end

  def upload_resume(student, resume_param) do
    if resume_param do
      case StudentResume.store({resume_param, student}) do
        {:ok, _} ->
          Repo.update(
            Student.changeset(
              student,
              %{"resume" => resume_param.filename}
            )
          )
        {:error, error} -> {:error, error}
      end
    else
      {:ok, student}
    end
  end
end

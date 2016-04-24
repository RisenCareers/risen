defmodule Risen.StudentService do

  alias Risen.Repo
  alias Risen.Student
  alias Risen.StudentPic
  alias Risen.StudentResume

  def upload_pic(conn, pic_param) do
    student = conn.assigns[:student]
    if pic_param do
      case StudentPic.store({pic_param, student}) do
        {:ok, _} ->
          st_chgset = Student.changeset(student, %{"pic" => pic_param.filename})
          Repo.update(st_chgset)
        {:error, error} -> {:error, error}
      end
    else
      {:ok, student}
    end
  end

  def upload_resume(conn, resume_param) do
    student = conn.assigns[:student]
    if resume_param do
      case StudentResume.store({resume_param, student}) do
        {:ok, _} ->
          st_chgset = Student.changeset(student, %{"resume" => resume_param.filename})
          Repo.update(st_chgset)
        {:error, error} -> {:error, error}
      end
    else
      {:ok, student}
    end
  end
end

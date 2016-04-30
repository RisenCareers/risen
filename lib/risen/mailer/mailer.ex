defmodule Risen.Mailer do
  require Logger

  alias Risen.Repo

  @from "hello@risen.careers"

  def send_student_welcome_email(student) do
    student = Repo.preload(student, [:account])
    send_email to: student.account.email,
               from: @from,
               subject: "Welcome to Risen Careers",
               text: render("student_welcome.text", %{ name: student.name }),
               html: render("student_welcome.html", %{ name: student.name })
    send_email to: @from,
               from: @from,
               subject: "Welcome to Risen Careers",
               text: render("student_welcome.text", %{ name: student.name }),
               html: render("student_welcome.html", %{ name: student.name })
  end

  def send_student_ready_email(student) do
    student = Repo.preload(student, [:account])
    send_email to: student.account.email,
               from: @from,
               subject: "Scheduled!",
               text: render("student_ready.text", %{}),
               html: render("student_ready.html", %{})
  end

  def send_student_employer_interested_email(student, _employer) do
    student = Repo.preload(student, [:account])
    send_email to: student.account.email,
               from: @from,
               subject: "Employer Interested",
               text: render("student_employer_interested.text", %{}),
               html: render("student_employer_interested.html", %{})
  end

  def send_employer_welcome_email(employer) do
    employer = Repo.preload(employer, [:admins])
    send_email to: Enum.map(employer.admins, &(&1.email)),
               from: @from,
               subject: "Welcome to Risen Careers",
               text: render("employer_welcome.text", %{ name: employer.name }),
               html: render("employer_welcome.html", %{ name: employer.name })
    send_email to: @from,
               from: @from,
               subject: "Welcome to Risen Careers",
               text: render("employer_welcome.text", %{ name: employer.name }),
               html: render("employer_welcome.html", %{ name: employer.name })
  end

  def send_employer_batch_email(employer, _batch) do
    employer = Repo.preload(employer, [:admins])
    send_email to: Enum.map(employer.admins, &(&1.email)),
               from: @from,
               subject: "New Batch",
               text: render("employer_batch.text", %{}),
               html: render("employer_batch.html", %{})
  end

  defp render(template, params) do
    Phoenix.View.render_to_string(Risen.EmailView, "#{template}", params)
  end

  defp send_email(opts) do
    Logger.debug "Sending email #{inspect opts}"
    Toniq.enqueue(Risen.MailerWorker, opts)
  end
end

import Ecto.Query, only: [from: 1, from: 2]

Enum.each([
  Risen.BatchStudent,
  Risen.EmployerStudentInterest,
  Risen.Student,
  Risen.Batch,
  Risen.School,
  Risen.EmployerMajor,
  Risen.EmployerAdmin,
  Risen.Employer,
  Risen.AccountRole,
  Risen.Account,
  Risen.Major,
  Risen.Role
], fn(m) -> from(ar in m) |> Risen.Repo.delete_all end)

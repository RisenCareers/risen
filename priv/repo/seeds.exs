use Timex

import Comeonin.Bcrypt

alias Risen.Repo
alias Risen.Role
alias Risen.Account
alias Risen.AccountRole
alias Risen.School
alias Risen.Major
alias Risen.Student
alias Risen.Batch
alias Risen.BatchStudent
alias Risen.Employer
alias Risen.EmployerAdmin
alias Risen.EmployerMajor

# Roles

s_role = Repo.insert!(%Role{name: "Student"})
e_role = Repo.insert!(%Role{name: "EmployerAdmin"})
a_role = Repo.insert!(%Role{name: "RisenAdmin"})

#
# Major
#

cs_major = Repo.insert!(%Major{name: "Computer Science"})
hm_major = Repo.insert!(%Major{name: "Humanities"})
an_major = Repo.insert!(%Major{name: "Anthropology"})

#
# School
#

pcc = Repo.insert!(%School{
  name: "Pensacola Christian College",
  abbreviation: "PCC",
  slug: "pcc"
})

bju = Repo.insert!(%School{
  name: "Bob Jones University",
  abbreviation: "BJU",
  slug: "bju"
})

#
# Student
#

account = Repo.insert!(%Account{
  email: "student.01@example.com",
  password_hash: hashpwsalt("testing")
})

Repo.insert!(%AccountRole{ role_id: s_role.id, account_id: account.id })

student = Repo.insert!(%Student{
  account_id: account.id,
  school_id: pcc.id,
  major_id: cs_major.id,
  name: "Vicky Leong",
  phone: "(555) 555-5555",
  ideal_role: "Front-end Developer",
  visa_status: List.first(Student.visa_statuses),
  job_type: List.first(Student.job_types),
  location_preference: "New York, NY; Remote",
  status: "Pending"
})

#
# Batch
#

batch_1 = Repo.insert!(%Batch{ sent_at: DateTime.now })
Repo.insert!(%BatchStudent{ batch_id: batch_1.id, student_id: student.id })

batch_2 = Repo.insert!(%Batch{ sent_at: Timex.shift(DateTime.now, days: -3) })
Repo.insert!(%BatchStudent{ batch_id: batch_2.id, student_id: student.id })

#
# Employer
#

ea_account = Repo.insert!(%Account{
  email: "employer.admin.01@example.com",
  password_hash: hashpwsalt("testing")
})

Repo.insert!(%AccountRole{
  role_id: e_role.id,
  account_id: ea_account.id
})

employer = Repo.insert!(%Employer{
  name: "OneHope",
  slug: "onehope"
})

employer_admin = Repo.insert!(%EmployerAdmin{
  employer_id: employer.id,
  account_id: ea_account.id
})

Repo.insert!(%EmployerMajor{ employer_id: employer.id, major_id: cs_major.id })
Repo.insert!(%EmployerMajor{ employer_id: employer.id, major_id: hm_major.id })

use Timex

import Comeonin.Bcrypt
import Risen.Factory

alias Risen.Repo
alias Risen.Account
alias Risen.AccountRole
alias Risen.Role
alias Risen.Major
alias Risen.Batch
alias Risen.BatchStudent
alias Risen.Employer
alias Risen.EmployerMajor
alias Risen.EmployerAdmin

#
# Majors
#

Repo.insert!(%Major{name: "Computer Science"})
Repo.insert!(%Major{name: "Business Management"})
Repo.insert!(%Major{name: "Humanities"})
Repo.insert!(%Major{name: "Nursing"})

#
# School
#

pcc = build_school(%{
  name: "Pensacola Christian College",
  abbreviation: "PCC",
  slug: "pcc"
})

bju = build_school(%{
  name: "Bob Jones University",
  abbreviation: "BJU",
  slug: "bju"
})

#
# Batches
#

batches = Enum.map([1, 3, 6, 9], fn(t) ->
  Repo.insert!(%Batch{
    sent_at: DateTime.set(
      Timex.shift(DateTime.now, days: (t * -1)), [millisecond: 0]
    )
  })
end)
# Upcoming Batch
# upcoming_batch = Repo.insert!(%Batch{})
# batches = batches ++ [upcoming_batch]

#
# Students
#

Enum.each(Enum.to_list(1..15), fn(x) ->
  student = build_student(%{ account: %{ email: "student.#{x}@example.com" } })
  if student.status == "Ready" do
    batch = Enum.at(batches, Enum.random(Enum.to_list(0..(length(batches) - 1))))
    Repo.insert!(%BatchStudent{
      batch_id: batch.id,
      student_id: student.id
    })
  end
end)

#
# Employer
#

e_role = Repo.get_by(Role, name: "EmployerAdmin")
a_role = Repo.get_by(Role, name: "RisenAdmin")

cs_major = Repo.get_by(Major, name: "Computer Science")
hm_major = Repo.get_by(Major, name: "Humanities")

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

#
# Admin
#

a_account = Repo.insert!(%Account{
  email: "admin.01@example.com",
  password_hash: hashpwsalt("testing")
})

Repo.insert!(%AccountRole{ role_id: a_role.id, account_id: a_account.id })

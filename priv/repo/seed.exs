import Comeonin.Bcrypt

alias Risen.Repo
alias Risen.Role
alias Risen.Account
alias Risen.AccountRole
alias Risen.Batch
alias Risen.Major

# Roles

st_role = Repo.insert!(%Role{name: "Student"})
ea_role = Repo.insert!(%Role{name: "EmployerAdmin"})
ad_role = Repo.insert!(%Role{name: "RisenAdmin"})

# Admins

vicky = Repo.insert!(%Account{
  email: "vleong2332@gmail.com",
  password_hash: hashpwsalt("vicky password")
})
jesse = Repo.insert!(%Account{
  email: "donjesse@gmail.com",
  password_hash: hashpwsalt("jesse password")
})
steve = Repo.insert!(%Account{
  email: "stjowa@gmail.com",
  password_hash: hashpwsalt("steve password")
})

Enum.each([vicky, jesse, steve], fn(a) ->
  Repo.insert!(%AccountRole{
    role_id: ad_role.id,
    account_id: a.id
  })
end)

# Insert Pending Batch

Repo.insert!(%Batch{})

# Majors (TBD)

Repo.insert!(%Major{name: "Computer Science"})
Repo.insert!(%Major{name: "Humanities"})
Repo.insert!(%Major{name: "Anthropology"})

alias Risen.Repo
alias Risen.Role
alias Risen.Major

Repo.insert!(%Role{name: "Student"})
Repo.insert!(%Role{name: "EmployerAdmin"})
Repo.insert!(%Role{name: "RisenAdmin"})

Repo.insert!(%Major{name: "Computer Science"})
Repo.insert!(%Major{name: "Humanities"})
Repo.insert!(%Major{name: "Anthropology"})

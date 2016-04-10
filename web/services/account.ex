defmodule Risen.AccountService do
  def starting_link(model, conn) do
    cond do
      Risen.Account.has_role?(model, "RisenAdmin") ->
        Risen.Router.Helpers.admin_index_path(conn, :index)
      Risen.Account.has_role?(model, "EmployerAdmin") ->
        model = Risen.Repo.preload(model, [:employers])
        Risen.Router.Helpers.employer_students_path(conn, :index, hd(model.employers).slug)
      Risen.Account.has_role?(model, "Student") ->
        model = Risen.Repo.preload(model, [:students])
        Risen.Router.Helpers.student_profile_path(conn, :edit, hd(model.students).id)
    end
  end

  def friendly_name(model) do
    cond do
      Risen.Account.has_role?(model, "RisenAdmin") ->
        "Admin"
      Risen.Account.has_role?(model, "EmployerAdmin") ->
        model = Risen.Repo.preload(model, [:employers])
        hd(model.employers).name
      Risen.Account.has_role?(model, "Student") ->
        model = Risen.Repo.preload(model, [:students])
        hd(model.students).name
    end
  end
end

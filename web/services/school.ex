defmodule Risen.SchoolService do
  use Timex

  alias Risen.Repo
  alias Risen.SchoolLogo

  def upload_logo(school, logo_param) do
    SchoolLogo.store({logo_param, school})
    Repo.update!(
      Ecto.Changeset.change(
        school,
        logo: logo_param.filename
      )
    )
  end
end

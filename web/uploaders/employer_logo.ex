defmodule Risen.EmployerLogo do
  use Arc.Definition

  @versions [:original]

  def acl(:original, _), do: :public_read

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Override the storage directory:
  def storage_dir(version, {file, scope}) do
    "uploads/employers/logos/#{scope.id}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(version, scope) do
    "https://placehold.it/500x500"
  end
end

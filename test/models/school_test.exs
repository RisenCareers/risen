defmodule Risen.SchoolTest do
  use Risen.ModelCase

  alias Risen.School

  @valid_attrs %{logo: "some content", name: "some content", slug: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = School.changeset(%School{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = School.changeset(%School{}, @invalid_attrs)
    refute changeset.valid?
  end
end

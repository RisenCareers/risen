defmodule Risen.EmployerMajorTest do
  use Risen.ModelCase

  alias Risen.EmployerMajor

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EmployerMajor.changeset(%EmployerMajor{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EmployerMajor.changeset(%EmployerMajor{}, @invalid_attrs)
    refute changeset.valid?
  end
end

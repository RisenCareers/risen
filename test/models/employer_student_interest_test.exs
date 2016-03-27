defmodule Risen.EmployerStudentInterestTest do
  use Risen.ModelCase

  alias Risen.EmployerStudentInterest

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EmployerStudentInterest.changeset(%EmployerStudentInterest{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EmployerStudentInterest.changeset(%EmployerStudentInterest{}, @invalid_attrs)
    refute changeset.valid?
  end
end

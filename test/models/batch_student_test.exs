defmodule Risen.BatchStudentTest do
  use Risen.ModelCase

  alias Risen.BatchStudent

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = BatchStudent.changeset(%BatchStudent{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = BatchStudent.changeset(%BatchStudent{}, @invalid_attrs)
    refute changeset.valid?
  end
end

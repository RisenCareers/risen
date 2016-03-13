defmodule Risen.StudentTest do
  use Risen.ModelCase

  alias Risen.Student

  @valid_attrs %{job_type: "some content", location_preference: "some content", name: "some content", phone: "some content", pic: "some content", resume: "some content", status: "some content", visa_status: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Student.changeset(%Student{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Student.changeset(%Student{}, @invalid_attrs)
    refute changeset.valid?
  end
end

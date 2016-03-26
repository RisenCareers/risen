defmodule Risen.AttachmentTest do
  use Risen.ModelCase

  alias Risen.Attachment

  @valid_attrs %{byte_size: 42, content_type: "some content", name: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Attachment.changeset(%Attachment{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Attachment.changeset(%Attachment{}, @invalid_attrs)
    refute changeset.valid?
  end
end

defmodule Risen.Tokens do
  def generate_token(length = 32) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end

defmodule ChessQuo.Games.Tokens do
  @doc "
  Generate a 6-character game code (A–Z0–9 only)

  There are 36^6 (2,176,782,336) possible codes.
  "
  def game_code do
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    length = 6

    for _ <- 1..length, into: "" do
      <<Enum.random(alphabet)>>
    end
  end

  @doc "Generate a random secret token"
  def secret do
    :crypto.strong_rand_bytes(32)
    |> Base.encode64()
  end
end

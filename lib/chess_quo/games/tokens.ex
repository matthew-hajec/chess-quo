defmodule ChessQuo.Games.Tokens do
  @doc "
  Generate a 6-character game code (A–Z0–9 only)

  There are 36^6 (2,176,782,336) possible codes.
  "
  def game_code do
    # If these parameters change, `possible_code?/1` must also change.
    alphabet = ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    length = 6

    for _ <- 1..length, into: "" do
      <<Enum.random(alphabet)>>
    end
  end

  @doc "
  Check if a game code is valid. (correct length and character set)

  A game code is possibly valid if it could be returned by `game_code/0`
  "
  def possible_code?(code) when is_binary(code) do
    String.match?(code, ~r/^[A-Z0-9]{6}$/)
  end

  def possible_code(_code), do: false

  @doc "Generate a random secret token"
  def secret do
    :crypto.strong_rand_bytes(32)
    |> Base.encode64()
  end
end

defmodule ChessQuo.Games.Tokens do
  @behaviour ChessQuo.Games.TokenBehaviour

  @doc """
  Generate a 6-character game code (A–Z0–9 only)

  There are 36^6 (2,176,782,336) possible codes.

  ## Examples

      iex> code = ChessQuo.Games.Tokens.game_code()
      iex> String.length(code)
      6
      iex> code =~ ~r/^[A-Z0-9]{6}$/
      true
      iex> ChessQuo.Games.Tokens.possible_code?(code)
      true
  """
  def game_code do
    # If these parameters change, `possible_code?/1` must also change.
    alphabet = ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    length = 6

    for _ <- 1..length, into: "" do
      <<Enum.random(alphabet)>>
    end
  end

  @doc """
  Check if a game code is valid. (correct length and character set)

  A game code is possibly valid if it could be returned by `game_code/0`.

  ## Examples

      iex> ChessQuo.Games.Tokens.possible_code?("ABC123")
      true

      iex> ChessQuo.Games.Tokens.possible_code?("abc123")  # lowercase not allowed
      false

      iex> ChessQuo.Games.Tokens.possible_code?("AAAAAA7") # too long
      false

      iex> ChessQuo.Games.Tokens.possible_code?("AAAAA!")  # invalid character
      false

      iex> ChessQuo.Games.Tokens.possible_code?("Z9Z9Z9")
      true
  """
  def possible_code?(code) when is_binary(code) do
    String.match?(code, ~r/^[A-Z0-9]{6}$/)
  end

  @doc """
  Non-`?` variant returns `false` for non-binaries.

  ## Examples

      iex> ChessQuo.Games.Tokens.possible_code(:not_a_binary)
      false
  """
  def possible_code(_code), do: false

  @doc """
  Generate a random secret token (Base64-encoded 32 bytes).

  The result is Base64 (standard alphabet) of 32 bytes, so it’s 43 characters + "=" padding.

  ## Examples

      iex> s = ChessQuo.Games.Tokens.secret()
      iex> String.length(s)
      44
      iex> s =~ ~r/^[A-Za-z0-9+\\/]{43}=$/
      true
      iex> byte_size(Base.decode64!(s))
      32
  """
  def secret do
    :crypto.strong_rand_bytes(32)
    |> Base.encode64()
  end
end

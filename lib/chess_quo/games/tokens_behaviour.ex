defmodule ChessQuo.Games.TokenBehaviour do
  @callback game_code() :: String.t()
  @callback secret() :: String.t()
  @callback possible_code?(String.t()) :: boolean()
end

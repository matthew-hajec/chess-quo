ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ChessQuo.Repo, :manual)
# Define the mock tokens implementation
Mox.defmock(ChessQuo.Games.MockTokens, for: ChessQuo.Games.TokenBehaviour)
# Use the mock tokens implementation in tests
Application.put_env(:chess_quo, :tokens, ChessQuo.Games.MockTokens)

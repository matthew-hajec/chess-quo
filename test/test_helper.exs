ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ChessQuo.Repo, :manual)
# Define the mock tokens implementation
Mox.defmock(ChessQuo.Games.MockTokens, for: ChessQuo.Games.TokenBehaviour)
# Use the mock tokens implementation in tests
Application.put_env(:chess_quo, :tokens, ChessQuo.Games.MockTokens)

# Define the mock for ruleset
Mox.defmock(ChessQuo.Games.Rules.MockRules, for: ChessQuo.Games.RulesBehaviour)
# Use the mock ruleset implementations in tests
Application.put_env(:chess_quo, :ruleset_mods, %{"chess" => ChessQuo.Games.Rules.Chess, "mock" => ChessQuo.Games.Rules.MockRules})

defmodule ChessQuo.Repo do
  use Ecto.Repo,
    otp_app: :chess_quo,
    adapter: Ecto.Adapters.Postgres
end

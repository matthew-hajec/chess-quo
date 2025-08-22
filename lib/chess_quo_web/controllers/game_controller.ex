defmodule ChessQuoWeb.GameController do
  use ChessQuoWeb, :controller

  def create(conn, _params) do
    render(conn, :create)
  end
end

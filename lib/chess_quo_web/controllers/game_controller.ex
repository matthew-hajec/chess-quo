defmodule ChessQuoWeb.GameController do
  use ChessQuoWeb, :controller

  def new(conn, _params) do
    render(conn, :new)
  end
end

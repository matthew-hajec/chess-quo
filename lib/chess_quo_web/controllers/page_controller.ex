defmodule ChessQuoWeb.PageController do
  use ChessQuoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

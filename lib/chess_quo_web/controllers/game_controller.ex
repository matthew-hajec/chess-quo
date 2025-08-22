defmodule ChessQuoWeb.GameController do
  use ChessQuoWeb, :controller

  alias ChessQuo.Games

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"color_preference" => color}) when color in ["white", "black", "random"] do
    color = if color == "random", do: Enum.random(["white", "black"]), else: color

    case Games.create_game do
      {:ok, game} ->
        player_secret = if color == "white", do: game.white_secret, else: game.black_secret

        conn
        |> put_session(:player_secret, player_secret)
        |> put_session(:player_color, color)
        |> redirect(to: ~p"/game/#{game.code}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to create game. Please try again.")
        |> redirect(to: ~p"/game/create")
    end
  end
end

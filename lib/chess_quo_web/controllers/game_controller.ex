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
        |> put_resp_cookie("player_secret", player_secret, max_age: 60 * 60 * 24 * 30) # 30 days
        |> put_resp_cookie("player_color", color, max_age: 60 * 60 * 24 * 30) # 30 days
        |> redirect(to: ~p"/game/#{game.code}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to create game. Please try again.")
        |> redirect(to: ~p"/game/create")
    end
  end
end

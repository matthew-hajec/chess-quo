defmodule ChessQuoWeb.GameController do
  use ChessQuoWeb, :controller

  alias ChessQuo.Games

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"color_preference" => color}) when color in ["white", "black", "random"] do
    color = if color == "random", do: Enum.random(["white", "black"]), else: color
    password = Map.get(conn.params, "password", "") |> String.trim()

    case Games.create_game("chess", color, password) do
      {:ok, game} ->
        player_secret = if color == "white", do: game.white_secret, else: game.black_secret

        conn
        |> put_session(:player_secret, player_secret)
        |> put_session(:player_color, color)
        |> redirect(to: ~p"/play/#{game.code}")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to create game. Please try again.")
        |> redirect(to: ~p"/lobby/create")
    end
  end

  def join(conn, %{"code" => code}) do
    code = String.trim(code) |> String.upcase()

    with true <- Games.possible_code(code),
         {:ok, _game} <- Games.get_game(code) do
          render(conn, :join, code: code)
    else
      _ ->
        conn
        |> put_flash(:error, "Game not found.")
        |> redirect(to: ~p"/")
    end
  end

  def post_join(conn, %{"code" => code, "password" => password}) do
    code = String.trim(code) |> String.upcase()

    if Games.possible_code(code) do
      case Games.join_by_password(code, password) do
        {:ok, color, secret} ->
          conn
          |> put_session(:player_secret, secret)
          |> put_session(:player_color, color)
          |> redirect(to: ~p"/play/#{code}")

        {:error, :not_found} ->
          conn
          |> put_flash(:error, "Game not found.")
          |> redirect(to: ~p"/")

        {:error, :invalid_password} ->
          conn
          |> put_flash(:error, "Invalid password.")
          |> redirect(to: ~p"/lobby/join/#{code}")

        {:error, :full} ->
          conn
          |> put_flash(:error, "Game is full.")
          |> redirect(to: ~p"/")
      end
    else
      conn
      |> put_flash(:error, "Invalid game code.")
      |> redirect(to: ~p"/")
    end
  end
end

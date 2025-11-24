defmodule ChessQuoWeb.Router do
  use ChessQuoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChessQuoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :admin_auth
  end

  def admin_auth(conn, _opts) do
    # Simple basic auth for demonstration purposes
    username = System.get_env("ADMIN_USERNAME")
    password = System.get_env("ADMIN_PASSWORD")

    if is_nil(username) or is_nil(password) do
      # Send an unauthorized response if credentials are not set
      conn
      |> Plug.Conn.send_resp(401, "Unauthorized")
      |> Plug.Conn.halt()
    else
      Plug.BasicAuth.basic_auth(conn, username: username, password: password)
    end
  end

  scope "/", ChessQuoWeb do
    pipe_through :browser

    get "/", HomeController, :home

    get "/lobby/create", GameController, :new
    post "/lobby/create", GameController, :create

    get "/lobby/join/:code", GameController, :join
    post "/lobby/join/:code", GameController, :post_join

    live "/online/:code", OnlineGameLive, :show
  end

  scope "/admin", ChessQuoWeb.Admin do
    import Phoenix.LiveDashboard.Router

    pipe_through [:browser, :admin]

    live_dashboard "/dashboard", metrics: ChessQuoWeb.Telemetry
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChessQuoWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:chess_quo, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

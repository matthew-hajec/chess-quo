defmodule ChessQuo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChessQuoWeb.Telemetry,
      ChessQuo.Repo, # Comment/uncomment here and in `config/config.exs` to toggle the database.
      {DNSCluster, query: Application.get_env(:chess_quo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ChessQuo.PubSub},
      # Start a worker by calling: ChessQuo.Worker.start_link(arg)
      # {ChessQuo.Worker, arg},
      # Start to serve requests, typically the last entry
      ChessQuoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChessQuo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChessQuoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

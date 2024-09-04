defmodule Mse25.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Mse25Web.Telemetry,
      {DNSCluster, query: Application.get_env(:mse25, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Mse25.PubSub},
      # Start a worker by calling: Mse25.Worker.start_link(arg)
      # {Mse25.Worker, arg},
      # Start to serve requests, typically the last entry
      Mse25Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mse25.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Mse25Web.Endpoint.config_change(changed, removed)
    :ok
  end
end

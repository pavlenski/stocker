defmodule StockerApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StockerApiWeb.Telemetry,
      StockerApi.Repo,
      {DNSCluster, query: Application.get_env(:stocker_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: StockerApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: StockerApi.Finch},
      # Start a worker by calling: StockerApi.Worker.start_link(arg)
      # {StockerApi.Worker, arg},
      # Start to serve requests, typically the last entry
      StockerApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StockerApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StockerApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

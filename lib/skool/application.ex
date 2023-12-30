defmodule Skool.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SkoolWeb.Telemetry,
      Skool.Repo,
      {DNSCluster, query: Application.get_env(:skool, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Skool.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Skool.Finch},
      # Start a worker by calling: Skool.Worker.start_link(arg)
      # {Skool.Worker, arg},
      # Start to serve requests, typically the last entry
      SkoolWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Skool.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SkoolWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

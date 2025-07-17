defmodule Src.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SrcWeb.Telemetry,
      Src.Repo,
      {DNSCluster, query: Application.get_env(:src, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Src.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Src.Finch},
      # Start a worker by calling: Src.Worker.start_link(arg)
      # {Src.Worker, arg},
      # Start to serve requests, typically the last entry
      SrcWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Src.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SrcWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

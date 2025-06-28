defmodule Actioneer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ActioneerWeb.Telemetry,
      Actioneer.Repo,
      {DNSCluster, query: Application.get_env(:actioneer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Actioneer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Actioneer.Finch},
      # Start a worker by calling: Actioneer.Worker.start_link(arg)
      # {Actioneer.Worker, arg},
      # Start to serve requests, typically the last entry
      ActioneerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Actioneer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ActioneerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule AshGqlSubBug.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AshGqlSubBugWeb.Telemetry,
      AshGqlSubBug.Repo,
      {DNSCluster, query: Application.get_env(:ash_gql_sub_bug, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AshGqlSubBug.PubSub},
      # Start a worker by calling: AshGqlSubBug.Worker.start_link(arg)
      # {AshGqlSubBug.Worker, arg},
      # Start to serve requests, typically the last entry
      AshGqlSubBugWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AshGqlSubBug.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AshGqlSubBugWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule UpaTikPortal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UpaTikPortalWeb.Telemetry,
      UpaTikPortal.Repo,
      {DNSCluster, query: Application.get_env(:upa_tik_portal, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UpaTikPortal.PubSub},
      UpaTikPortal.Recruitment.QrTokenStore,
      # Start to serve requests, typically the last entry
      UpaTikPortalWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UpaTikPortal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UpaTikPortalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

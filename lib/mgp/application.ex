defmodule Mgp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Mgp.Repo,
      # Start the Telemetry supervisor
      MgpWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mgp.PubSub},
      # Start the Endpoint (http/https)
      MgpWeb.Endpoint,
      # Start a worker by calling: Mgp.Worker.start_link(arg)
      # {Mgp.Worker, arg}
      Mgp.Sync
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mgp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MgpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

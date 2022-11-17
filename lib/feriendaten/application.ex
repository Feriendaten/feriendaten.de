defmodule Feriendaten.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FeriendatenWeb.Telemetry,
      # Start the Ecto repository
      Feriendaten.Repo,
      # Start the LegacyEcto repository
      Feriendaten.LegacyRepo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Feriendaten.PubSub},
      # Start Finch
      {Finch, name: Feriendaten.Finch},
      # Start the Endpoint (http/https)
      FeriendatenWeb.Endpoint
      # Start a worker by calling: Feriendaten.Worker.start_link(arg)
      # {Feriendaten.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Feriendaten.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FeriendatenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

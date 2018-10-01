defmodule VibeqModem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    registry_name = VibeqModem.Registry

    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: registry_name},
      {VibeqModem.GpioSupervisor, registry: registry_name},
      {VibeqModem.ModemWorker, registry: registry_name},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VibeqModem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

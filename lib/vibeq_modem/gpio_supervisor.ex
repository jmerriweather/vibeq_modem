defmodule VibeqModem.GpioSupervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    registry = Keyword.get(opts, :registry, VibeqModem.Registry)

    children = [
      start_pin(registry, "gps-power", 46, :output),
      start_pin(registry, "modem-soft-power", 45, :output),
      start_pin(registry, "modem-hard-power", 44, :output),
      start_pin(registry, "modem-activity-led", 69, :output),
      start_pin(registry, "modem-netlight-led", 22, :output)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_pin(registry, name, pin, pin_direction, opts \\ []) do
    opts = Keyword.put(opts, :name, via(registry, name))
    %{
      id: :"#{name}",
      start: {ElixirALE.GPIO, :start_link, [pin, pin_direction, opts]}
    }
  end

  def via(registry, name) do
    {:via, Registry, {registry, name}}
  end
end

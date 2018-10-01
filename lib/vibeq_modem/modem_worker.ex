defmodule VibeqModem.ModemWorker do
  use GenServer

  alias ElixirALE.GPIO

  def start_link(opts) do
    IO.puts("Options: #{inspect opts}")
    registry = Keyword.pop(opts, :registry, VibeqModem.Registry)
    IO.puts("Registry: #{inspect registry}")
    GenServer.start_link(__MODULE__, registry, opts)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: { __MODULE__, :start_link, [opts]}
    }
  end

  def init(registry) do
    {:ok, %{registry: registry}, {:continue, :initialise_modem}}
  end

  def handle_continue(:initialise_modem, state = %{registry: registry}) do
    initialise_modem(registry)

    {:noreply, state}
  end

  def initialise_modem(registry) do
    # Turn on GPS Power
    GPIO.write(via(registry, "gps-power"), 1)

    # Turn on modem Soft power
    GPIO.write(via(registry, "modem-soft-power"), 1)

    # Turn on modem hard power
    GPIO.write(via(registry, "modem-hard-power"), 1)

    # Reset acitivity led
    GPIO.write(via(registry, "modem-activity-led"), 0)

    # Reset acitivity led
    GPIO.write(via(registry, "modem-netlight-led"), 0)

    soft_power_modem(registry)
  end

  def soft_power_modem(registry) do
    # Turn off modem Soft power
    GPIO.write(via(registry, "modem-soft-power"), 0)
    # wait 5 ms
    Process.sleep(500)
    # Turn on modem Soft power
    GPIO.write(via(registry, "modem-soft-power"), 1)
    Process.sleep(100)
    # Turn off modem Soft power
    GPIO.write(via(registry, "modem-soft-power"), 0)
  end

  def via(registry, name) do
    {:via, Registry, {registry, name}}
  end
end

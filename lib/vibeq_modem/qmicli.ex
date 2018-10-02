defmodule VibeqModem.Qmicli do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: { __MODULE__, :start_link, [opts]}
    }
  end

  def init(opts) do
    device = Keyword.get(opts, :device)
    apn = Keyword.get(opts, :apn)

    #System.cmd("qmicli", ["--device", "/dev/cdc-wdm0", "--set-expected-data-format", "raw-ip"], stderr_to_stdout: true)
    #System.cmd("qmicli", ["--device", "/dev/cdc-wdm0", "--set-expected-data-format", "raw-ip"], stderr_to_stdout: true)

    {:ok, %{device: device, apn: apn}, {:continue, :set_expected_data_format}}
  end

  def handle_continue(:set_expected_data_format, state = %{device: device, apn: apn}) do
    exec_command("qmicli", ["--device", device, "--set-expected-data-format", "raw-ip"])

    {:noreply, state, {:continue, :wds_start_network}}
  end

  def handle_continue(:wds_start_network, state = %{device: device, apn: apn}) do
    exec_command("qmicli", ["--device", device, "--wds-start-network", "apn='#{apn}'", "--client-no-release-cid"], )

    {:noreply, state}
  end

  def terminate(_reason, state) do

    :ok
  end

  def exec_command(cmd, params, opts \\ []) do
    opts = Keyword.merge([stderr_to_stdout: true], opts)

    {response, _} = System.cmd(cmd, params, opts)

    handle_qmicli(response)
  end

  def handle_qmicli(message, state) do

    IO.puts("Message: #{inspect message}")

    {:noreply, state}
  end
end

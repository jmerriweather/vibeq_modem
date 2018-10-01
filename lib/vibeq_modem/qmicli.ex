defmodule Qmicli do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    device = Keyword.get(opts, :device)
    apn = Keyword.get(opts, :apn)

    priv_path = :code.priv_dir(:nerves_network)
    port_path = '#{priv_path}/qmicli_wrapper'

    args = [
      "qmicli",
      "--device",
      device,
      "--set-expected-data-format",
      "raw-ip",
      "--wds-start-network",
      "apn='#{apn}'",
      "--client-no-release-cid"
    ]

    port =
      Port.open({:spawn_executable, port_path}, [
        {:args, args},
        :exit_status,
        :stderr_to_stdout,
        {:line, 256}
      ])

    {:ok, %{ifname: ifname, port: port}}
  end

  def terminate(_reason, state) do
    if Port.info(state.port) do
      # Send the command to our wrapper to shut everything down.
      Port.command(state.port, <<3>>)
      Port.close(state.port)
    end

    :ok
  end

  def handle_info({_, {:exit_status, 0}}, state) do
    {:stop, :normal, state}
  end

  def handle_info({_, {:exit_status, _}}, state) do
    {:stop, :port_exit, state}
  end

  def handle_info({_, {:data, {:eol, message}}}, state) do
    message = message
    |> List.to_string()

    IO.puts("Message: #{inspect message}")

    {:noreply, state}
  end
end

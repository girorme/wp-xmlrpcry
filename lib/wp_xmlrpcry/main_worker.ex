defmodule WpXmlrpcry.MainWorker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:xmlrpc_brute, url}, _from, state) do
    IO.puts("process #{inspect(self())} consuming url: #{url}")
    Process.sleep(4000)
    {:reply, url, state}
  end
end

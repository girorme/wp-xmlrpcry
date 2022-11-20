defmodule WpXmlrpcry.Result do
  use GenServer

  def start_link(results) do
    GenServer.start_link(__MODULE__, results, name: __MODULE__)
  end

  def store_result(result) do
    GenServer.cast(__MODULE__, {:store_result, result})
  end

  def get_results() do
    GenServer.call(__MODULE__, :get_results)
  end

  @impl true
  def init(results) do
    {:ok, results}
  end

  @impl true
  def handle_call(:get_results, _from, current_results) do
    {:reply, current_results, current_results}
  end

  @impl true
  def handle_cast({:store_result, result}, current_results) do
    current_results = [result | current_results]
    {:noreply, current_results}
  end
end

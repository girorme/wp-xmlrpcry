defmodule WpXmlrpcry.Worker do
  def call(agent, url, num_of_requests, opts) do
    work(url, agent, num_of_requests, opts)
  end

  defp work(url, agent, 0, _) do
    Agent.update(agent, fn list -> [{url}|list] end)
  end

  defp work(url, agent, requests_to_do, opts) do
    seconds = 1..2 |> Enum.random()
    Process.sleep(:timer.seconds(seconds))
    work(url, agent, requests_to_do - 1, opts)
  end
end

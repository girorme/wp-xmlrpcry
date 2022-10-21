defmodule WpXmlrpcry.Worker do
  def work(progress_channel, url) do
    Process.sleep(:timer.seconds(1..5 |> Enum.random))
    send(progress_channel, url)
  end
end

defmodule WpXmlrpcry do
  alias WpXmlrpcry.{Worker, Util, Progress}
  #require Reporter

  def main(args) do
    args
    |> parse_args()
    |> process()
  end

  def process(args) do
    IO.puts(Util.banner())

    if args[:help] do
      IO.puts(Util.help())
      System.halt(0)
    end

    urls = 1..9999
    total = Enum.count(urls)
    progress_channel = Progress.start_progress(finished: 0, total: total)

    Task.async_stream(
      urls,
      &(Worker.work(progress_channel, &1)),
      max_concurrency: 200,
      timeout: :infinity,
      ordered: false
    ) |> Stream.run()
  end

  defp parse_args(args) do
    {parsed, _argv, _} = OptionParser.parse(args,
      switches: [
        concurrency: :integer,
        output: :string,
        help: :boolean
      ],
      aliases: [c: :concurrency, h: :help, o: :output]
    )

    parsed
  end
end

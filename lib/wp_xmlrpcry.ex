defmodule WpXmlrpcry do
  alias WpXmlrpcry.Report
  alias WpXmlrpcry.{Progress, Result, TimeUtils, Worker, Util}

  def main(args) do
    args
    |> Util.parse_args()
    |> start()
  end

  def start(args) do
    IO.puts(Util.banner())

    Util.validate_args(args)

    config = %{
      url_list: nil,
      userlist: nil,
      wordlist: nil,
      progress_channel: nil,
      default_users: true,
      default_passwords: true
    }

    start_time = DateTime.utc_now()

    config
    |> Util.get_user_preferences(args)
    |> Util.get_urls(args[:urls])
    |> Util.get_users(args[:users])
    |> Util.get_passwords(args[:wordlist])
    |> start_progress()
    |> start_workers()

    total_time =
      DateTime.diff(DateTime.utc_now(), start_time)
      |> TimeUtils.sec_to_str()

    final_report =
      Report.get_results(Result.get_results(),
        time_lapsed: total_time,
        output: args[:output]
      )

    TableRex.quick_render!(
      [Map.values(final_report[:statistics])],
      Map.keys(final_report[:statistics]),
      "Results"
    )
    |> IO.puts()

    cred_flat = Enum.map(final_report[:credentials_info], fn x -> [x[:url], x[:credentials]] end)

    final_result =
      TableRex.quick_render!(
        cred_flat,
        ["url", "credentials"],
        "Results"
      )

    Report.save_results_to_file(
      final_result,
      args[:output]
    )

    IO.puts("Results writen to: #{args[:output]}")
  end

  defp start_progress(config) do
    total = Enum.count(config[:url_list])
    %{config | progress_channel: Progress.start_progress(finished: 0, total: total)}
  end

  defp start_workers(config) do
    Task.async_stream(
      config[:url_list],
      &Worker.start(
        config[:progress_channel],
        url: &1,
        users: config[:userlist],
        wordlist: config[:wordlist]
      ),
      max_concurrency: 200,
      timeout: :infinity,
      ordered: false
    )
    |> Stream.run()
  end
end

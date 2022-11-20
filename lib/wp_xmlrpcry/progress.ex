defmodule WpXmlrpcry.Progress do
  alias WpXmlrpcry.Result

  def start_progress(finished: finished, total: total) do
    spawn(fn -> notify_progress(finished, total) end)
  end

  defp notify_progress(finished, total) do
    ProgressBar.render(finished, total, format())

    finished =
      receive do
        url_result ->
          Result.store_result(url_result)
          finished + 1
      end

    notify_progress(finished, total)
  end

  defp format() do
    [
      bar_color: [IO.ANSI.magenta()],
      blank_color: [IO.ANSI.magenta()],
      bar: "█",
      blank: "░",
      suffix: :count
    ]
  end
end

defmodule WpXmlrpcry.Report do
  def format_result(result, url) do
    {success, error} = Enum.split_with(result, fn attempt -> attempt[:success] == true end)

    %{
      url: url,
      total_tries: Enum.count(success) + Enum.count(error),
      credentials_found?: Enum.count(success) > 0,
      credentials: success
    }
  end

  def get_results(results, opts) do
    {total_success, total_cred_tries} =
      Enum.reduce(results, {0, 0}, fn
        %{credentials_found?: true, total_tries: tries}, {total_success, total_cred_tries} ->
          {total_success + 1, total_cred_tries + tries}

        %{total_tries: tries}, {total_success, total_cred_tries} ->
          {total_success, total_cred_tries + tries}
      end)

    statistics = %{
      "creds_found" => Integer.to_string(total_success),
      "usr_pw_tries" => Integer.to_string(total_cred_tries),
      "output" => opts[:output],
      "time" => opts[:time_lapsed]
    }

    credentials_info =
      Enum.reduce(results, [], fn
        url_info = %{credentials_found?: cred_found}, acc ->
          unless cred_found do
            acc
          else
            cred = List.first(url_info[:credentials])

            url =
              Map.new()
              |> Map.put(:url, url_info[:url])
              |> Map.put(:credentials, "#{cred[:username]}:#{cred[:password]}")

            [url | acc]
          end
      end)

    %{
      statistics: statistics,
      credentials_info: credentials_info
    }
  end

  def save_results_to_file(results, file) do
    File.write(file, results)
  end
end

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

  def get_results_in_table(results, opts) do
    {total_success, total_cred_tries} =
      Enum.reduce(results, {0, 0}, fn
        %{credentials_found?: true, total_tries: tries}, {total_success, total_cred_tries} ->
          {total_success + 1, total_cred_tries + tries}

        %{total_tries: tries}, {total_success, total_cred_tries} ->
          {total_success, total_cred_tries + tries}
      end)

    formatted_result = %{
      creds_found: total_success,
      usr_pw_tries: total_cred_tries,
      output: ""
    }

    formatted_result =
      if opts[:time_lapsed] do
        Map.put(formatted_result, :time, opts[:time_lapsed])
      else
        formatted_result
      end

    Scribe.print(formatted_result, colorize: true)
  end
end

defmodule WpXmlrpcry.Report do
  def format_result(result, url) do
    {success, error} = Enum.split_with(result, fn attempt -> attempt[:success] == true end)

    %{
      url: url,
      total_tries: Enum.count(success) + Enum.count(error),
      credentials: success
    }
  end
end

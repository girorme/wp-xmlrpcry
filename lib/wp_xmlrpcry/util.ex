defmodule WpXmlrpcry.Util do
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
end

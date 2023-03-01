work = fn ->
  seconds = :timer.seconds(1)
  IO.puts("Sleeping for #{seconds}")
  Process.sleep(:timer.seconds(seconds))
end

# debug
results = [
  %{
    credentials: [],
    credentials_found?: false,
    total_tries: 4,
    url: "https://www.site.com/xmlrpc.php"
  }
]
opt = [time_lapsed: "23 seconds", output: "output.txt"]

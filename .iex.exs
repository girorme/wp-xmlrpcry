work = fn ->
  seconds = :timer.seconds(1)
  IO.puts("Sleeping for #{seconds}")
  Process.sleep(:timer.seconds(seconds))
end

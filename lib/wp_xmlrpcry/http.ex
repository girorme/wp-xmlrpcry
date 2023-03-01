defmodule WpXmlrpcry.Http do
  def post(url, payload) do
    HTTPoison.post(url, payload, [{"Content-Type", "application/xml"}],
      hackney: [:insecure]
    )
  end

  def text_in_body?(body, pattern), do: String.match?(body, pattern)
  def extract_body(%HTTPoison.Response{body: body}), do: body
end

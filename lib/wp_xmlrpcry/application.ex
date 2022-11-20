defmodule WpXmlrpcry.Application do
  @moduledoc false
  use Application

  alias WpXmlrpcry.Result

  @impl true
  def start(_type, _args) do
    children = [
      Result
    ]

    opts = [strategy: :one_for_one, name: WpXmlrpcry.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

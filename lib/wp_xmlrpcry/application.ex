defmodule WpXmlrpcry.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  defp poolboy_config do
    [
      name: {:local, :main_worker},
      worker_module: WpXmlrpcry.MainWorker,
      size: 5,
      max_overflow: 0
    ]
  end

  @impl true
  def start(_type, _args) do
    children = [
      :poolboy.child_spec(:main_worker, poolboy_config())
    ]

    opts = [strategy: :one_for_one, name: WpXmlrpcry.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

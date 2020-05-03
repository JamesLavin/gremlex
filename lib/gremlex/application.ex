defmodule Gremlex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  defp parse_port(port) when is_number(port), do: port
  defp parse_port(""), do: 8182
  defp parse_port(:not_set), do: :not_set

  defp parse_port(port_string) when is_binary(port_string) do
    case Integer.parse(port_string) do
      {port, ""} ->
        port

      _ ->
        raise ArgumentError, message: "Invalid Port: #{port_string}"
    end
  end

  defp parse_secure(:not_set), do: false
  defp parse_secure(is_secure), do: is_secure

  defp get_env(param) do
    case Confex.fetch_env(:gremlex, param) do
      {:ok, value} -> value
      :error -> :not_set
    end
  end

  defp build_app_worker(:not_set, :not_set, :not_set, :not_set, :not_set, _) do
    []
  end

  defp build_app_worker(host, port, path, pool_size, max_overflow, secure) do
    pool_options = [
      name: {:local, :gremlex},
      worker_module: Gremlex.Client,
      size: pool_size,
      max_overflow: max_overflow
    ]

    [
      :poolboy.child_spec(:gremlex, pool_options,
        host: host,
        port: port,
        path: path,
        secure: secure
      )
    ]
  end

  def start(_type, _args) do
    # List all child processes to be supervised
    host = get_env(:host)
    port = get_env(:port) |> parse_port()
    path = get_env(:path)
    pool_size = get_env(:pool_size)
    max_overflow = get_env(:max_overflow)
    secure = get_env(:secure) |> parse_secure()

    children = build_app_worker(host, port, path, pool_size, max_overflow, secure)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gremlex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

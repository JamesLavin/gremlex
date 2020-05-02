defmodule Gremlex.Client do
  @moduledoc """
  Gremlin Websocket Client
  """

  @type state :: %{socket: Socket.Web.t()}

  @type response ::
          {:ok, list()}
          | {:error, :unauthorized, String.t()}
          | {:error, :malformed_request, String.t()}
          | {:error, :invalid_request_arguments, String.t()}
          | {:error, :server_error, String.t()}
          | {:error, :script_evaluation_error, String.t()}
          | {:error, :server_timeout, String.t()}
          | {:error, :server_serialization_error, String.t()}
          | {:error, :websocket_closed, nil}

  require Logger
  alias Gremlex.Request
  alias Gremlex.Deserializer

  defp parse_delay(value) when is_binary(value) do
    case Integer.parse(value) do
      {delay, ""} ->
        delay

      _ ->
        Logger.warn("Found invalid ping delay value: #{value} -- Defaulting to 0")
        0
    end
  end

  defp parse_delay(delay) when is_number(delay), do: delay

  defp parse_delay(_), do: 0

  @spec get_delay() :: number()
  defp get_delay do
    case Confex.fetch_env(:gremlex, :ping_delay) do
      {:ok, value} ->
        parse_delay(value)

      _ ->
        0
    end
  end

  @spec start_link({String.t(), number(), String.t(), boolean()}) :: pid()
  def start_link({host, port, path, secure}) do
    case Socket.Web.connect(host, port, path: path, secure: secure) do
      {:ok, socket} ->
        GenServer.start_link(__MODULE__, socket, [])

      error ->
        Logger.error("Error establishing connection to server: #{inspect(error)}")
        GenServer.start_link(__MODULE__, nil, [])
    end
  end

  @spec init(nil) :: {:stop, String.t()}
  def init(nil) do
    {:stop, "Socket is missing"}
  end

  @spec init(Socket.Web.t()) :: state
  def init(socket) do
    state = %{socket: socket}
    schedule()
    {:ok, state}
  end

  # Public Methods

  @doc """
  Accepts a graph which it converts into a query and queries the database.

  Params:
  * query - A `Gremlex.Graph.t` or raw String query
  * timeout (Default: 5000ms) - Timeout in milliseconds to pass to GenServer and Task.await call
  """
  @spec query(Gremlex.Graph.t() | String.t(), number() | :infinity) :: response
  def query(query, timeout \\ 5000) do
    payload =
      query
      |> Request.new()
      |> Poison.encode!()

    :poolboy.transaction(
      :gremlex,
      fn worker_pid ->
        GenServer.call(worker_pid, {:query, payload, timeout}, timeout)
      end,
      timeout
    )
  end

  # Server Methods
  @spec handle_call({:query, String.t(), number() | :infinity}, pid(), state) ::
          {:reply, response, state}
  def handle_call({:query, payload, timeout}, _from, %{socket: socket} = state) do
    Socket.Web.send!(socket, {:text, payload})

    {time, result} =
      measure(fn ->
        task = Task.async(fn -> recv(socket) end)
        Task.await(task, timeout)
      end)

    Logger.metadata(
      query: payload,
      time: time,
      result_status: elem(result, 0),
      result: elem(result, 1)
    )

    Logger.info("Query #{payload} took #{time} seconds and result `#{elem(result, 0)}`")

    {:reply, result, state}
  end

  def handle_info(:ping, %{socket: socket} = state) do
    Logger.debug("Ping!")
    Socket.Web.send!(socket, {:pong, ""})
    schedule()
    {:noreply, state}
  end

  defp schedule do
    delay = get_delay()
    Logger.debug("Delay: #{delay}")

    if delay > 0 do
      Process.send_after(self(), :ping, delay)
    end
  end

  # Private Methods
  @spec recv(Socket.Web.t(), list()) :: response
  defp recv(socket, acc \\ []) do
    case Socket.Web.recv!(socket) do
      {:close, :abnormal, nil} ->
        {:error, :websocket_closed, nil}

      {:text, data} ->
        response = Poison.decode!(data)
        result = Deserializer.deserialize(response)
        status = response["status"]["code"]
        error_message = response["status"]["message"]
        # Continue to block until we receive a 200 status code
        case status do
          200 ->
            {:ok, acc ++ result}

          204 ->
            {:ok, []}

          206 ->
            recv(socket, acc ++ result)

          401 ->
            {:error, :unauthorized, error_message}

          409 ->
            {:error, :malformed_request, error_message}

          499 ->
            {:error, :invalid_request_arguments, error_message}

          500 ->
            {:error, :server_error, error_message}

          597 ->
            {:error, :script_evaluation_error, error_message}

          598 ->
            {:error, :server_timeout, error_message}

          599 ->
            {:error, :server_serialization_error, error_message}
        end

      {:ping, _} ->
        # Keep the connection alive
        Socket.Web.send!(socket, {:pong, ""})
        recv(socket, acc)
    end
  end

  def measure(function) do
    {time, result} = function |> :timer.tc()
    {Kernel./(time, 1_000_000), result}
  end
end

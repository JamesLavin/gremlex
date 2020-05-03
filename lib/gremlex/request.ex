defmodule Gremlex.Request do
  alias Gremlex.Graph
  @derive [Poison.Encoder]
  @op "eval"
  @processor ""
  @enforce_keys [:op, :processor, :requestId, :args]
  defstruct [:op, :processor, :requestId, :args]

  @type t ::
          %Gremlex.Request{
            requestId: String.t(),
            args: any(),
            op: String.t(),
            processor: String.t()
          }

  @doc """
  Accepts plain query or a graph and returns a Request.
  """
  @spec new(String.t() | :queue.queue(any())) :: t()
  def new(query) when is_binary(query) do
    args = %{gremlin: query, language: "gremlin-groovy"}
    %Gremlex.Request{requestId: UUID.uuid4(), args: args, op: @op, processor: @processor}
  end

  def new(query) do
    new(Graph.encode(query))
  end
end

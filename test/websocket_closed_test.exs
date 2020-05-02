defmodule Gremlex.WebsocketClosedTest do
  use Gremlex
  use ExUnit.Case

  test "returns an error tuple for long queries" do
    {:ok, query} = File.read("test/support/long_query.groovy")
    {status, reason, msg} = Gremlex.Client.query(query)
    assert(status == :error)
    assert(reason == :websocket_closed)
    assert(msg == nil)
  end
end

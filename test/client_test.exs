defmodule Gremlex.ClientTests do
  use Gremlex
  use ExUnit.Case

  describe "query/1" do
    test "that it can return a successful query" do
      {result, response} = g() |> v() |> query
      assert result == :ok
      assert Enum.count(response) > 0
    end

    test "returns an error :script_evaluation_error for a bad request" do
      {result, response, error_message} = g() |> to(1) |> query
      assert result == :error
      assert response == :script_evaluation_error
      assert error_message != ""
    end

    test "allows you to create a new vertex" do
      {result, response} = g() |> add_v("person") |> property("name", "jasper") |> query
      assert Enum.count(response) == 1
      assert result == :ok
      [vertex] = response
      assert vertex.label == "person"
      assert vertex.properties == %{name: ["jasper"]}
    end

    test "allows you to create a new vertex with multiline property" do
      address = "23480 Park Sorrento, Suite 100 Calabasas, CA 91302"

      {result, response} =
        g()
        |> add_v("person")
        |> property("name", "jasper")
        |> property("address", address)
        |> query

      assert Enum.count(response) == 1
      assert result == :ok
      [vertex] = response
      assert vertex.label == "person"

      assert vertex.properties ==
               %{
                 name: ["jasper"],
                 address: [address]
               }
    end

    test "allows you to create a new vertex without a property" do
      {result, response} = g() |> add_v("person") |> query
      assert Enum.count(response) == 1
      assert result == :ok
      [vertex] = response
      assert vertex.label == "person"
    end

    test "allows you to create a new vertex with a namespace" do
      {_, [s]} = g() |> add_v("foo") |> add_namespace() |> query()
      {_, [t]} = g() |> add_v("bar") |> add_namespace("baz") |> query()
      assert s.properties.namespace == ["gremlex"]
      assert t.properties.namespace == ["baz"]
    end

    test "allows you to create a relationship between two vertices" do
      {_, [s]} = g() |> add_v("foo") |> property("name", "bar") |> query()
      {_, [t]} = g() |> add_v("bar") |> property("name", "baz") |> query()
      {result, response} = g() |> v(s.id) |> add_e("isfriend") |> to(t) |> query
      assert result == :ok
      [edge] = response
      assert edge.label == "isfriend"
    end

    test "allows you to get all edges" do
      {result, response} = g() |> e() |> query
      assert result == :ok

      case response do
        [] ->
          {_res, edges} =
            g()
            |> v(0)
            |> add_e("edge_2_electric_booglaoo")
            |> to(%Gremlex.Vertex{id: 1, properties: nil, label: "no"})
            |> query

          assert Enum.count(edges) > 0

        edges ->
          assert Enum.count(edges) > 0
      end
    end

    test "returns empty list when there is no content retrieved" do
      {_, response} =
        g() |> v() |> has_label("person") |> has("doesntExist", "doesntExist") |> query

      assert(response == [])
    end

    test "allow to execute plain query" do
      {result, response} = query("g.addV('person').property('name', 'jasper')")
      assert Enum.count(response) == 1
      assert result == :ok
      [vertex] = response
      assert vertex.label == "person"
      assert vertex.properties == %{name: ["jasper"]}
    end
  end
end

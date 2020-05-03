defmodule Gremlex.GraphTests do
  import Gremlex.Graph
  alias Gremlex.{Vertex, Edge, Graph}
  use ExUnit.Case
  use ExUnitProperties
  alias :queue, as: Queue

  describe "g/0" do
    test "returns a new queue" do
      assert g() == Queue.new()
      assert {[], []} == g()
    end
  end

  describe "anonymous/0" do
    test "adds __ function to the queue" do
      actual_graph = anonymous()
      expected_graph = Queue.in({"__", []}, Queue.new())
      assert {[{"__", []}], ''} == expected_graph
      assert actual_graph == expected_graph
    end
  end

  describe "add_vertex/3" do
    test "adds an addVertex function to the queue when no properties" do
      properties = []
      actual_graph = g() |> add_vertex("vertex label", properties)
      expected_graph = Queue.in({"addVertex", ["vertex label", []]}, Queue.new())
      assert {[{"addVertex", ["vertex label", []]}], []} == expected_graph
      assert actual_graph == expected_graph
      assert "g.addVertex(label,'vertex label')" = actual_graph |> Graph.encode()
    end

    test "adds an addVertex function to the queue with properties" do
      properties = [{"bestHockeyTeam", "Bruins"}, {"bestFootballTeam", "Patriots"}]
      actual_graph = g() |> add_vertex("vertex label", properties)
      expected_graph = Queue.in({"addVertex", ["vertex label", properties]}, Queue.new())
      assert {[{"addVertex", ["vertex label", properties]}], []} == expected_graph
      assert actual_graph == expected_graph

      assert "g.addVertex(label,'vertex label','bestHockeyTeam','Bruins','bestFootballTeam','Patriots')" =
               actual_graph |> Graph.encode()
    end
  end

  describe "add_v/1" do
    test "adds an addV function to the queue" do
      actual_graph = g() |> add_v(1)
      expected_graph = Queue.in({"addV", [1]}, Queue.new())
      assert {[{"addV", [1]}], []} == expected_graph
      assert actual_graph == expected_graph
    end

    test "can be chained" do
      actual_graph =
        g()
        |> add_v(1)
        |> add_v(2)
        |> add_v(3)
        |> add_v(4)

      expected_graph = {[{"addV", [4]}, {"addV", [3]}, {"addV", [2]}], [{"addV", [1]}]}
      assert actual_graph == expected_graph
    end
  end

  describe "add_e/1" do
    test "adds an addE step to the queue" do
      actual_graph = g() |> add_e("foo")
      expected_graph = Queue.in({"addE", ["foo"]}, Queue.new())
      assert expected_graph == {[{"addE", ["foo"]}], []}
      assert actual_graph == expected_graph
    end

    test "can be chained" do
      actual_graph = g() |> add_e("foo") |> add_e("bar") |> add_e("baz")
      expected_graph = {[{"addE", ["baz"]}, {"addE", ["bar"]}], [{"addE", ["foo"]}]}
      assert actual_graph == expected_graph
    end
  end

  describe "aggregate/2" do
    test "adds an aggregate function to the queue" do
      actual_graph = g() |> Graph.aggregate("foo")
      expected_graph = Queue.in({"aggregate", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "barrier/2" do
    test "adds a barrier function with parameter to the queue" do
      actual_graph = g() |> Graph.barrier(1)
      expected_graph = Queue.in({"barrier", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "barrier/1" do
    test "adds a barrier function to the queue" do
      actual_graph = g() |> Graph.barrier()
      expected_graph = Queue.in({"barrier", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "coin/2" do
    test "adds a coin function to the queue" do
      actual_graph = g() |> Graph.coin(1.0)
      expected_graph = Queue.in({"coin", [1.0]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has_label/1" do
    test "adds a hasLabel function to the queue" do
      actual_graph = g() |> has_label("foo")
      expected_graph = Queue.in({"hasLabel", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has/2" do
    test "adds a has function to the queue" do
      actual_graph = g() |> has("foo")
      expected_graph = Queue.in({"has", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has/3" do
    test "adds a has function to the queue" do
      actual_graph = g() |> has("foo", "bar")
      expected_graph = Queue.in({"has", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has_namespace/1" do
    test "adds a has function with namespace to the queue" do
      actual_graph = g() |> has_namespace()
      expected_graph = Queue.in({"has", ["namespace", "gremlex"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has_namespace/2" do
    test "adds a has function with namespace to the queue" do
      actual_graph = g() |> has_namespace("bar")
      expected_graph = Queue.in({"has", ["namespace", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has_not/2" do
    test "adds a hasNot function to the queue" do
      actual_graph = g() |> Graph.has_not("age")
      expected_graph = Queue.in({"hasNot", ["age"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "key/1" do
    test "adds a key function to the queue" do
      actual_graph = g() |> Graph.key()
      expected_graph = Queue.in({"key", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has_id/2" do
    test "adds a hasId function to the queue" do
      actual_graph = g() |> Graph.has_id(20)
      expected_graph = Queue.in({"hasId", [20]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has_key/1" do
    test "adds a hasKey function to the queue" do
      actual_graph = g() |> Graph.has_key(["name", "age"])
      expected_graph = Queue.in({"hasKey", ["name", "age"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "add_namespace/1" do
    test "adds a property function with namespace to the queue" do
      actual_graph = g() |> add_namespace()
      expected_graph = Queue.in({"property", ["namespace", "gremlex"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "add_namespace/2" do
    test "adds a property function with namespace to the queue" do
      actual_graph = g() |> add_namespace("bar")
      expected_graph = Queue.in({"property", ["namespace", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "property/2" do
    test "adds a property function to the queue" do
      actual_graph = g() |> Graph.property("foo")
      expected_graph = Queue.in({"property", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "property/3" do
    test "adds a property function to the queue" do
      actual_graph = g() |> Graph.property("foo", "bar")
      expected_graph = Queue.in({"property", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "property/4" do
    test "adds a property function to the queue as single" do
      actual_graph = g() |> Graph.property(:single, "foo", "bar")
      expected_graph = Queue.in({"property", [:single, "foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "adds a property function to the queue as list" do
      actual_graph = g() |> Graph.property(:list, "foo", "bar")
      expected_graph = Queue.in({"property", [:list, "foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "adds a property function to the queue as set" do
      actual_graph = g() |> Graph.property(:set, "foo", "bar")
      expected_graph = Queue.in({"property", [:set, "foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "properties/2" do
    test "adds a properties function to the queue" do
      actual_graph = g() |> Graph.properties("foo")
      expected_graph = Queue.in({"properties", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "properties/1" do
    test "adds a properties function to the queue" do
      actual_graph = g() |> Graph.properties()
      expected_graph = Queue.in({"properties", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "store/2" do
    test "adds a store function to the queue" do
      actual_graph = g() |> Graph.store("foo")
      expected_graph = Queue.in({"store", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "value_map/1" do
    test "adds a valueMap function to the queue" do
      actual_graph = g() |> Graph.value_map()
      expected_graph = Queue.in({"valueMap", []}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "adds a valueMap function to the queue with list of properties" do
      actual_graph = g() |> Graph.value_map(["foo", "bar"])
      expected_graph = Queue.in({"valueMap", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "value_map/2 when value is string" do
    test "adds a valueMap function to the queue" do
      actual_graph = g() |> Graph.value_map("foo")
      expected_graph = Queue.in({"valueMap", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "value_map/2 when value is a list" do
    test "adds a valueMap function to the queue" do
      actual_graph = g() |> Graph.value_map(["foo", "bar"])
      expected_graph = Queue.in({"valueMap", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "values/2" do
    test "adds a value function the queue" do
      actual_graph = g() |> values("foo")
      expected_graph = Queue.in({"values", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "v/1" do
    test "adds a V function to the queue" do
      actual_graph = g() |> v()
      expected_graph = Queue.in({"V", []}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "creates a vertex when the id is a number" do
      check all(n <- integer()) do
        actual_graph = v(n)
        expected_graph = %Vertex{id: n, label: ""}
        assert actual_graph == expected_graph
      end
    end
  end

  describe "v/2" do
    test "adds a V function for an id to the queue" do
      actual_graph = g() |> v(1)
      expected_graph = Queue.in({"V", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "adds a V function when given a vertex to the queue" do
      actual_graph = g() |> v(%Vertex{id: 1, label: "foo"})
      expected_graph = Queue.in({"V", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "out_e/1" do
    test "adds an outE function to the queue" do
      actual_graph = g() |> out_e()
      expected_graph = Queue.in({"outE", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "out_e/2" do
    test "adds an outE function to the queue" do
      actual_graph = g() |> out_e("foo")
      expected_graph = Queue.in({"outE", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "adds an outE function to the queue with list of edges" do
      actual_graph = g() |> out_e(["foo", "bar"])
      expected_graph = Queue.in({"outE", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "out/2" do
    test "adds an out function with an edge to the queue" do
      actual_graph = g() |> out("foo")
      expected_graph = Queue.in({"out", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "out/1" do
    test "adds an out function to the queue" do
      actual_graph = g() |> out()
      expected_graph = Queue.in({"out", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "in_/2" do
    test "adds an in function with an edge to the queue" do
      actual_graph = g() |> in_("foo")
      expected_graph = Queue.in({"in", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "in_/1" do
    test "adds an in function to the queue" do
      actual_graph = g() |> in_()
      expected_graph = Queue.in({"in", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "or_/1" do
    test "adds an or function to the queue" do
      actual_graph = g() |> or_()
      expected_graph = Queue.in({"or", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "and_/1" do
    test "adds an and function to the queue" do
      actual_graph = g() |> and_()
      expected_graph = Queue.in({"and", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "in_e/1" do
    test "adds an inE function to the queue" do
      actual_graph = g() |> in_e()
      expected_graph = Queue.in({"inE", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "in_e/2" do
    test "adds an inE function to the queue" do
      actual_graph = g() |> in_e("foo")
      expected_graph = Queue.in({"inE", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "adds an inE function to the queue with list of edges" do
      actual_graph = g() |> in_e(["foo", "bar"])
      expected_graph = Queue.in({"inE", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "in_v/1" do
    test "adds an inV function to the queue" do
      actual_graph = g() |> in_v()
      expected_graph = Queue.in({"inV", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "out_v/1" do
    test "adds an outV function to the queue" do
      actual_graph = g() |> out_v()
      expected_graph = Queue.in({"outV", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "both/1" do
    test "adds a both function to the queue" do
      actual_graph = g() |> both()
      expected_graph = Queue.in({"both", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "both/2" do
    test "adds a both function to the queue" do
      actual_graph = g() |> both("foo")
      expected_graph = Queue.in({"both", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "adds a both function to the queue with provided list" do
      actual_graph = g() |> both(["foo", "bar"])
      expected_graph = Queue.in({"both", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "both_e/1" do
    test "adds a bothE function to the queue" do
      actual_graph = g() |> both_e()
      expected_graph = Queue.in({"bothE", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "both_e/2" do
    test "adds a bothE function to the queue with provided list" do
      actual_graph = g() |> both_e(["foo", "bar"])
      expected_graph = Queue.in({"bothE", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "adds a bothE function to the queue" do
      actual_graph = g() |> both_e("foo")
      expected_graph = Queue.in({"bothE", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "both_v/1" do
    test "adds a bothV function to the queue" do
      actual_graph = g() |> both_v()
      expected_graph = Queue.in({"bothV", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "dedup/1" do
    test "adds an dedup function to the queue" do
      actual_graph = g() |> dedup()
      expected_graph = Queue.in({"dedup", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "to/2" do
    test "adds a to function to the queue" do
      actual_graph = g() |> to(1)
      expected_graph = Queue.in({"to", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "has_next/1" do
    test "adds a hasNext function to the queue" do
      actual_graph = g() |> has_next()
      expected_graph = Queue.in({"hasNext", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "next/1" do
    test "adds a next function to the queue" do
      actual_graph = g() |> next()
      expected_graph = Queue.in({"next", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "next/2" do
    test "adds a next function to the queue" do
      actual_graph = g() |> next(2)
      expected_graph = Queue.in({"next", [2]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "try_next/1" do
    test "adds a tryNext function to the queue" do
      actual_graph = g() |> try_next()
      expected_graph = Queue.in({"tryNext", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "to_list/1" do
    test "adds a toList function to the queue" do
      actual_graph = g() |> to_list()
      expected_graph = Queue.in({"toList", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "to_set/1" do
    test "adds a toSet function to the queue" do
      actual_graph = g() |> to_set()
      expected_graph = Queue.in({"toSet", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "to_bulk_set/1" do
    test "adds a toBulkSet function to the queue" do
      actual_graph = g() |> to_bulk_set()
      expected_graph = Queue.in({"toBulkSet", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "drop/1" do
    test "adds a drop function to the queue" do
      actual_graph = g() |> drop()
      expected_graph = Queue.in({"drop", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "iterate/1" do
    test "adds a iterate function to the queue" do
      actual_graph = g() |> iterate()
      expected_graph = Queue.in({"iterate", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "sum/1" do
    test "adds a sum function to the queue" do
      actual_graph = g() |> sum()
      expected_graph = Queue.in({"sum", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "min/1" do
    test "adds a min function to the queue" do
      actual_graph = g() |> min()
      expected_graph = Queue.in({"min", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "max/1" do
    test "adds a max function to the queue" do
      actual_graph = g() |> max()
      expected_graph = Queue.in({"max", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "identity/1" do
    test "adds a identity function to the queue" do
      actual_graph = g() |> identity()
      expected_graph = Queue.in({"identity", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "id/1" do
    test "adds a id function to the queue" do
      actual_graph = g() |> id()
      expected_graph = Queue.in({"id", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "cyclic_path/1" do
    test "adds a cyclicPath function to the queue" do
      actual_graph = g() |> cyclic_path()
      expected_graph = Queue.in({"cyclicPath", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "count/1" do
    test "adds a count function to the queue" do
      actual_graph = g() |> count()
      expected_graph = Queue.in({"count", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "count/2" do
    test "adds a count function to the queue" do
      actual_graph = g() |> count(:local)
      expected_graph = Queue.in({"count", [:local]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "group/1" do
    test "adds a group function to the queue" do
      actual_graph = g() |> group()
      expected_graph = Queue.in({"group", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "constant/2" do
    test "adds a constant function to the queue" do
      actual_graph = g() |> Graph.constant("foo")
      expected_graph = Queue.in({"constant", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "group_count/1" do
    test "adds a groupCount function to the queue" do
      actual_graph = g() |> group_count()
      expected_graph = Queue.in({"groupCount", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "group_count/2" do
    test "adds a groupCount function to the queue" do
      actual_graph = g() |> group_count("foo")
      expected_graph = Queue.in({"groupCount", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "within/1" do
    test "creates a queue with the within function using a range arg" do
      actual_graph = within(1..5)
      expected_graph = Queue.in({"within", [1..5]}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "creates a queue with the within function using a list arg" do
      actual_graph = within([1, 2, 3])
      expected_graph = Queue.in({"within", [1, 2, 3]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "without/1" do
    test "creates a queue with the without function using a range arg" do
      actual_graph = without(1..5)
      expected_graph = Queue.in({"without", [1..5]}, Queue.new())
      assert actual_graph == expected_graph
    end

    test "creates a queue with the without function using a list arg" do
      actual_graph = without([1, 2, 3])
      expected_graph = Queue.in({"without", [1, 2, 3]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "encode/1" do
    test "compiles queue into a query" do
      graph =
        g()
        |> v()
        |> has_label("Intent")
        |> has("name", "request.group")
        |> out("sedan")
        |> values("name")

      expected_query =
        "g.V().hasLabel('Intent').has('name', 'request.group').out('sedan').values('name')"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end

    test "compiles query with a vertex id correctly" do
      graph = g() |> v(1)
      expected_query = "g.V(1)"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end

    test "compiles query with a vertex" do
      graph = g() |> v(1) |> add_e("foo") |> to(v(2))
      expected_query = "g.V(1).addE('foo').to(V(2))"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end

    test "escape the query correctly with an apostrophe" do
      graph = g() |> v(1) |> add_e("foo' with apostrophe") |> to(v(2))
      expected_query = "g.V(1).addE('foo\\' with apostrophe').to(V(2))"

      actual_query = encode(graph)
      assert actual_query == expected_query

      graph = g() |> v(1) |> add_e("o' with apostrophe") |> to(v(2))
      expected_query = "g.V(1).addE('o\\' with apostrophe').to(V(2))"

      actual_query = encode(graph)
      assert actual_query == expected_query

      graph = g() |> v(1) |> add_e("' with apostrophe") |> to(v(2))
      expected_query = "g.V(1).addE('\\' with apostrophe').to(V(2))"

      actual_query = encode(graph)
      assert actual_query == expected_query

      graph = g() |> v(1) |> add_e("foo\\\\' with apostrophe") |> to(v(2))
      expected_query = "g.V(1).addE('foo\\\\\\' with apostrophe').to(V(2))"

      actual_query = encode(graph)
      assert actual_query == expected_query

      graph = g() |> v(1) |> add_e("foo\\\\\\\\' with apostrophe") |> to(v(2))
      expected_query = "g.V(1).addE('foo\\\\\\\\\\' with apostrophe').to(V(2))"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end

    test "do no escape already escaped apostrophe" do
      graph = g() |> v(1) |> add_e("foo\\' with apostrophe") |> to(v(2))
      expected_query = "g.V(1).addE('foo\\' with apostrophe').to(V(2))"

      actual_query = encode(graph)
      assert actual_query == expected_query

      graph = g() |> v(1) |> add_e("\\' with apostrophe") |> to(v(2))
      expected_query = "g.V(1).addE('\\' with apostrophe').to(V(2))"

      actual_query = encode(graph)
      assert actual_query == expected_query

      graph = g() |> v(1) |> add_e("\\\\' with apostrophe") |> to(v(2))
      expected_query = "g.V(1).addE('\\\\\\' with apostrophe').to(V(2))"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end

    test "compiles queue with nil value" do
      graph = g() |> v() |> has("name", nil)

      expected_query = "g.V().has('name', none)"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end

    test "compiles queue with range value" do
      graph = g() |> v() |> has("age", within(1..18))

      expected_query = "g.V().has('age', within(1..18))"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end

    test "add functions as arguments without prepending g. unless it is function v()" do
      graph =
        g()
        |> v("1")
        |> has_label("foo")
        |> fold()
        |> coalesce([g() |> unfold(), g() |> v("2")])

      expected_query = "g.V('1').hasLabel('foo').fold().coalesce(unfold(), g.V('2'))"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end

    test "deeply nested traversals" do
      graph =
        g()
        |> v("1")
        |> repeat(g() |> both_e() |> as("e") |> both_v() |> simple_path())
        |> until(g() |> has_label("foo") |> or_() |> loops() |> is(g() |> eq(2)))
        |> where(anonymous() |> not_(g() |> in_e("bar")))
        |> as("b")
        |> select(["e", "b"])

      expected_query =
        "g.V('1').repeat(bothE().as('e').bothV().simplePath())" <>
          ".until(hasLabel('foo').or().loops().is(eq(2)))" <>
          ".where(__.not(inE('bar'))).as('b').select('e', 'b')"

      actual_query = encode(graph)
      assert actual_query == expected_query
    end
  end

  describe "e/1" do
    test "adds an E function to the queue" do
      actual_graph = g() |> e()
      expected_graph = Queue.in({"E", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "e/2 with number" do
    test "adds an E function to the queue which accepts a numeric id" do
      actual_graph = g() |> e(1)
      expected_graph = Queue.in({"E", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "e/2 with string" do
    test "adds an E function to the queue which accepts a string id" do
      actual_graph = g() |> e("string-id")
      expected_graph = Queue.in({"E", ["string-id"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "e/2 with edge with numeric id" do
    test "adds an E function to the queue which accepts a string id" do
      edge = %Edge{
        id: 123,
        label: "someEdge",
        in_vertex: %Vertex{id: 345, label: "inVert"},
        out_vertex: %Vertex{id: 678, label: "outVert"},
        properties: %{}
      }

      actual_graph = g() |> e(edge)
      expected_graph = Queue.in({"E", [123]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "e/2 with edge with string id" do
    test "adds an E function to the queue which accepts a string id" do
      edge = %Edge{
        id: "edge-id",
        label: "someEdge",
        in_vertex: %Vertex{id: "in-v-id", label: "inVert"},
        out_vertex: %Vertex{id: "out-v-id", label: "outVert"},
        properties: %{}
      }

      actual_graph = g() |> e(edge)
      expected_graph = Queue.in({"E", ["edge-id"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "coalesce/2" do
    test "adds a coalesce function to the queue" do
      actual_graph = g() |> coalesce(["foo", "bar"])
      expected_graph = Queue.in({"coalesce", ["foo", "bar"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "fold/1" do
    test "adds a fold function to the queue" do
      actual_graph = g() |> fold()
      expected_graph = Queue.in({"fold", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "fold/2" do
    test "adds a fold function to the queue" do
      actual_graph = g() |> fold("foo")
      expected_graph = Queue.in({"fold", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "unfold/1" do
    test "adds a unfold function to the queue" do
      actual_graph = g() |> unfold()
      expected_graph = Queue.in({"unfold", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "unfold/2" do
    test "adds a unfold function to the queue" do
      actual_graph = g() |> unfold("foo")
      expected_graph = Queue.in({"unfold", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "as/2" do
    test "adds an as function to the queue" do
      actual_graph = g() |> as("foo")
      expected_graph = Queue.in({"as", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "select/2" do
    test "adds a select function to the queue" do
      actual_graph = g() |> select("foo")
      expected_graph = Queue.in({"select", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "by/2" do
    test "adds a by function to the queue" do
      actual_graph = g() |> by("foo")
      expected_graph = Queue.in({"by", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "by/3" do
    test "adds a by function to the queue" do
      actual_graph = g() |> by("foo", :decr)
      expected_graph = Queue.in({"by", ["foo", :decr]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "path/1" do
    test "adds a path function to the queue" do
      actual_graph = g() |> path()
      expected_graph = Queue.in({"path", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "simple_path/1" do
    test "adds a simplePath function to the queue" do
      actual_graph = g() |> simple_path()
      expected_graph = Queue.in({"simplePath", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "from/2" do
    test "adds a from function to the queue" do
      actual_graph = g() |> from("foo")
      expected_graph = Queue.in({"from", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "repeat/2" do
    test "adds a repeat function to the queue" do
      actual_graph = g() |> repeat("foo")
      expected_graph = Queue.in({"repeat", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "until/2" do
    test "adds a until function to the queue" do
      actual_graph = g() |> until("foo")
      expected_graph = Queue.in({"until", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "loops/1" do
    test "adds a loops function to the queue" do
      actual_graph = g() |> loops()
      expected_graph = Queue.in({"loops", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "is/2" do
    test "adds a is function to the queue" do
      actual_graph = g() |> is("foo")
      expected_graph = Queue.in({"is", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "inject/2" do
    test "adds a inject function to the queue" do
      actual_graph = g() |> inject("Daniel")
      expected_graph = Queue.in({"inject", ["Daniel"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "tail/1" do
    test "adds a tail function to the queue" do
      actual_graph = g() |> tail()
      expected_graph = Queue.in({"tail", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "tail/2" do
    test "adds a tail function to the queue" do
      actual_graph = g() |> tail(2)
      expected_graph = Queue.in({"tail", [2]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "eq/2" do
    test "adds a eq function to the queue" do
      actual_graph = g() |> eq(1)
      expected_graph = Queue.in({"eq", [1]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "where/2" do
    test "adds a where function to the queue" do
      actual_graph = g() |> where("foo")
      expected_graph = Queue.in({"where", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "not_/2" do
    test "adds a not function to the queue" do
      actual_graph = g() |> not_("foo")
      expected_graph = Queue.in({"not", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "cap/2" do
    test "adds a cap function to the queue" do
      actual_graph = g() |> cap("foo")
      expected_graph = Queue.in({"cap", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "datetime/2" do
    test "adds a datetime function to the queue" do
      actual_graph = g() |> datetime("foo")
      expected_graph = Queue.in({"datetime", ["foo"]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "other_v/1" do
    test "adds a otherV function to the queue" do
      actual_graph = g() |> other_v()
      expected_graph = Queue.in({"otherV", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "range/3" do
    test "adds a range function to the queue" do
      actual_graph = g() |> range(0, 2)
      expected_graph = Queue.in({"range", [0, 2]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "range/4" do
    test "adds a range function to the queue" do
      actual_graph = g() |> range(:local, 0, 2)
      expected_graph = Queue.in({"range", [:local, 0, 2]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "limit/2" do
    test "adds a limit function to the queue" do
      actual_graph = g() |> limit(3)
      expected_graph = Queue.in({"limit", [3]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "limit/3" do
    test "adds a limit function to the queue" do
      actual_graph = g() |> limit(:local, 2)
      expected_graph = Queue.in({"limit", [:local, 2]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "choose/3" do
    test "adds a choose function to the queue" do
      actual_graph = g() |> choose(g() |> has_label("TEST"), [g() |> v("1")])
      has_label_part = Queue.in({"hasLabel", ["TEST"]}, Queue.new())
      vertex_part = Queue.in({"V", ["1"]}, Queue.new())
      expected_graph = Queue.in({"choose", [has_label_part, vertex_part]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "emit/2" do
    test "adds a emit function to the queue" do
      actual_graph = g() |> emit(g() |> has_label("TEST"))
      has_label_part = Queue.in({"hasLabel", ["TEST"]}, Queue.new())
      expected_graph = Queue.in({"emit", [has_label_part]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "times/2" do
    test "adds a times function to the queue" do
      actual_graph = g() |> times(3)
      expected_graph = Queue.in({"times", [3]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "gt/2" do
    test "adds a gt function to the queue" do
      actual_graph = g() |> gt(3)
      expected_graph = Queue.in({"gt", [3]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "lt/2" do
    test "adds a lt function to the queue" do
      actual_graph = g() |> lt(3)
      expected_graph = Queue.in({"lt", [3]}, Queue.new())
      assert actual_graph == expected_graph
    end
  end

  describe "order/1" do
    test "adds a order function to the queue" do
      actual_graph = g() |> order()
      expected_graph = Queue.in({"order", []}, Queue.new())
      assert actual_graph == expected_graph
    end
  end
end

defmodule Gremlex.Path do
  alias Gremlex.Path
  alias Gremlex.Deserializer

  @type t :: %Path{labels: list(), objects: list()}
  @enforce_keys [:labels, :objects]
  @derive [Poison.Encoder]
  defstruct [:labels, :objects]

  def from_response(%{"labels" => labels, "objects" => objects}) do
    %Path{
      labels: Deserializer.deserialize(labels),
      objects: Deserializer.deserialize(objects)
    }
  end
end

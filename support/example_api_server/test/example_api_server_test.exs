defmodule ExampleApiServerTest do
  use ExUnit.Case
  doctest ExampleApiServer

  test "greets the world" do
    assert ExampleApiServer.hello() == :world
  end
end

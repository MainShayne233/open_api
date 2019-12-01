defmodule OpenApiTest do
  use ExUnit.Case
  doctest OpenApi

  test "greets the world" do
    assert OpenApi.hello() == :world
  end
end

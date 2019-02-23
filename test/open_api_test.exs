defmodule OpenAPITest do
  use ExUnit.Case

  defmodule MyAPI do
    use OpenAPI, schema: %{}
  end

  describe "__using__/1" do
    test "should properly invoke the macro" do
    end
  end
end

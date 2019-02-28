defmodule OpenAPITest do
  use ExUnit.Case

  defmodule(MyAPI) do
    use OpenAPI,
      schema:
        "test/support/schemas/tax_jar.json"
        |> File.read!()
        |> Jason.decode!()
  end

  describe "using/2" do
    test "should generate the API" do
      assert :ok
    end
  end
end

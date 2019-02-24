defmodule OpenAPITest do
  use ExUnit.Case

  @tax_jar_schema "test/support/schemas/tax_jar.json"
                  |> File.read!()
                  |> Jason.decode!()

  defmodule MyAPI do
    use OpenAPI, schema: @tax_jar_schema
  end

  describe "generate/2" do
    setup do
      %{tax_jar_schema: @tax_jar_schema}
    end

    test "should generate the API", %{tax_jar_schema: schema} do
      assert {:ok, _ast} = OpenAPI.generate([schema: schema], __MODULE__.MyAPI)
    end
  end
end

defmodule OpenAPI.ParserTest do
  use ExUnit.Case

  alias OpenAPI.Parser

  setup do
    raw_schema =
      "test/support/schemas/tax_jar.json"
      |> File.read!()
      |> Jason.decode!()

    %{raw_schema: raw_schema}
  end

  describe "parse_schema/1" do
    test "should successfully parse the raw_schema", %{raw_schema: raw_schema} do
      assert %OpenAPI.Schema{} = Parser.parse_schema(raw_schema)
    end
  end
end

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
      assert {:ok, schema} = Parser.parse_schema(raw_schema)

      assert schema.info.title == "defaultTitle"
      assert schema.info.description == "defaultDescription"
      assert schema.info.version == "0.0.1"

      assert schema.servers |> hd |> Map.get(:url) == "https://api.taxjar.com"

      assert %{"/v2/taxes" => taxes_path_item, "/v2/transactions/orders" => orders_path_item} =
        schema.paths

      assert taxes_path_item.post.description == "Auto generated using Swagger Inspector"
    end
  end
end

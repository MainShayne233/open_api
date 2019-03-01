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

      assert %{} =
               request_schema =
               taxes_path_item.post.request_body.content["application/json"].schema

      assert request_schema.type == :object

      assert %{} = properties = request_schema.properties

      assert properties["amount"].type == :integer
      assert properties["from_city"].type == :string
      assert properties["from_country"].type == :string
      assert properties["from_state"].type == :string
      assert properties["from_street"].type == :string
      assert properties["from_zip"].type == :string
      assert properties["shipping"].type == :number
      assert properties["to_city"].type == :string
      assert properties["to_country"].type == :string
      assert properties["to_state"].type == :string
      assert properties["to_street"].type == :string
      assert properties["to_zip"].type == :string

      assert properties["nexus_addresses"].type == :array
      assert properties["nexus_addresses"].items.type == :object
      assert properties["nexus_addresses"].items.properties["zip"].type == :string
      assert properties["nexus_addresses"].items.properties["country"].type == :string
      assert properties["nexus_addresses"].items.properties["city"].type == :string
      assert properties["nexus_addresses"].items.properties["street"].type == :string
      assert properties["nexus_addresses"].items.properties["id"].type == :string
      assert properties["nexus_addresses"].items.properties["state"].type == :string

      assert properties["line_items"].type == :array
      assert properties["line_items"].items.type == :object
      assert properties["line_items"].items.properties["product_tax_code"].type == :string
      assert properties["line_items"].items.properties["quantity"].type == :integer
      assert properties["line_items"].items.properties["discount"].type == :integer
      assert properties["line_items"].items.properties["id"].type == :string
      assert properties["line_items"].items.properties["unit_price"].type == :integer
    end
  end
end

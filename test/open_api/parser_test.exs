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
      assert Parser.parse_schema(raw_schema) ==
               %OpenAPI.Schema{
                 info: %OpenAPI.Schema.Info{
                   description: "defaultDescription",
                   title: "defaultTitle",
                   version: "0.0.1"
                 },
                 paths: %{
                   "/v2/taxes" => %OpenAPI.Schema.PathItem{
                     delete: nil,
                     get: nil,
                     head: nil,
                     options: nil,
                     parameters: nil,
                     patch: nil,
                     post: %OpenAPI.Schema.Operation{
                       description: "Auto generated using Swagger Inspector",
                       parameters: nil,
                       request_body: %OpenAPI.Schema.RequestBody{
                         content: %{
                           "application/json" => %OpenAPI.Schema.RequestPayload{
                             schema: %OpenAPI.Schema.DataSchema{
                               items: nil,
                               properties: %{
                                 "amount" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :integer
                                 },
                                 "from_city" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :string
                                 },
                                 "from_country" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :string
                                 },
                                 "from_state" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :string
                                 },
                                 "from_street" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :string
                                 },
                                 "from_zip" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :string
                                 },
                                 "line_items" => %OpenAPI.Schema.DataSchema{
                                   items: %OpenAPI.Schema.DataSchema{
                                     items: nil,
                                     properties: %{
                                       "discount" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :integer
                                       },
                                       "id" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :string
                                       },
                                       "product_tax_code" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :string
                                       },
                                       "quantity" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :integer
                                       },
                                       "unit_price" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :integer
                                       }
                                     },
                                     type: :object
                                   },
                                   properties: nil,
                                   type: :array
                                 },
                                 "nexus_addresses" => %OpenAPI.Schema.DataSchema{
                                   items: %OpenAPI.Schema.DataSchema{
                                     items: nil,
                                     properties: %{
                                       "city" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :string
                                       },
                                       "country" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :string
                                       },
                                       "id" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :string
                                       },
                                       "state" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :string
                                       },
                                       "street" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :string
                                       },
                                       "zip" => %OpenAPI.Schema.DataSchema{
                                         items: nil,
                                         properties: nil,
                                         type: :string
                                       }
                                     },
                                     type: :object
                                   },
                                   properties: nil,
                                   type: :array
                                 },
                                 "shipping" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :number
                                 },
                                 "to_city" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :string
                                 },
                                 "to_country" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :string
                                 },
                                 "to_state" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :string
                                 },
                                 "to_street" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :string
                                 },
                                 "to_zip" => %OpenAPI.Schema.DataSchema{
                                   items: nil,
                                   properties: nil,
                                   type: :string
                                 }
                               },
                               type: :object
                             }
                           }
                         },
                         description: nil
                       },
                       responses: nil
                     },
                     put: nil,
                     trace: nil
                   },
                   "/v2/transactions/orders" => %OpenAPI.Schema.PathItem{
                     delete: nil,
                     get: %OpenAPI.Schema.Operation{
                       description: "Auto generated using Swagger Inspector",
                       parameters: [
                         %OpenAPI.Schema.Parameter{
                           name: "to_transaction_date",
                           in: :query,
                           schema: %OpenAPI.Schema.DataSchema{
                             type: :string
                           },
                           example: "2019%2F02%2F01"
                         },
                         %OpenAPI.Schema.Parameter{
                           name: "from_transaction_date",
                           in: :query,
                           schema: %OpenAPI.Schema.DataSchema{
                             type: :string
                           },
                           example: "2019%2F01%2F01"
                         }
                       ],
                       request_body: nil,
                       responses: nil
                     },
                     head: nil,
                     options: nil,
                     parameters: nil,
                     patch: nil,
                     post: nil,
                     put: nil,
                     trace: nil
                   }
                 },
                 servers: [%OpenAPI.Schema.Server{url: "https://api.taxjar.com"}]
               }
    end
  end
end

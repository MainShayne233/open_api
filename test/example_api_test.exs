defmodule OpenAPI.ExampleAPITest do
  use ExUnit.Case
  alias OpenAPI.V3

  setup do
    open_api_document =
      "support/example_api_server/open_api_document.json"
      |> File.read!()
      |> Jason.decode!()

    %{
      open_api_document: open_api_document
    }
  end

  test "should be able to ingest the example app's OpenAPI document", %{
    open_api_document: open_api_document
  } do
    {:ok, document} = V3.Document.cast(open_api_document)

    assert %OpenAPI.V3.Document{
             info: %OpenAPI.V3.Info{
               title: "OpenAPI Example API Server",
               version: "1.0"
             },
             openapi: "3.0.0",
             paths: %{
               "/" => %OpenAPI.V3.PathItem{
                 description: nil,
                 get: %OpenAPI.V3.Operation{
                   operation_id: "HelloWorld",
                   parameters: [],
                   summary: "Hello World",
                   tags: ["Misc"],
                   responses: %{
                     "200" => %OpenAPI.V3.Response{
                       content: %{
                         "application/json" => %OpenAPI.V3.MediaType{
                           example: %{"hello" => "world"},
                           schema: %OpenAPI.V3.Reference{
                             ref: "#/components/schemas/HelloWorld"
                           }
                         }
                       },
                       description: ""
                     }
                   }
                 }
               }
             },
             components: %OpenAPI.V3.Components{
               schemas: %{
                 "HelloWorld" => %OpenAPI.V3.Schema{
                   example: %{"hello" => "world"},
                   properties: %{
                     "hello" => %OpenAPI.V3.Schema{
                       required: [],
                       type: "string"
                     }
                   },
                   required: ["hello"],
                   title: "HelloWorld",
                   type: "object"
                 }
               }
             }
           } = document
  end
end

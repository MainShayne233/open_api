defmodule OpenAPI.ExampleAPITest do
  use ExUnit.Case
  alias OpenAPI.V3

  @open_api_document_path "support/example_api_server/open_api_document.json"

  setup do
    open_api_document =
      @open_api_document_path
      |> File.read!()
      |> Jason.decode!()

    %{
      open_api_document: open_api_document
    }
  end

  describe "ingest" do
    test "should be able to ingest the example app's OpenAPI document", %{
      open_api_document: open_api_document
    } do
      {:ok, document} = V3.Document.cast(open_api_document)

      assert document =
               %OpenAPI.V3.Document{
                 components: %OpenAPI.V3.Components{
                   schemas: %{
                     "HelloWorld" => %OpenAPI.V3.Schema{
                       example: %{"hello" => "world"},
                       properties: %{
                         "hello" => %OpenAPI.V3.Schema{
                           example: nil,
                           properties: nil,
                           required: [],
                           title: nil,
                           type: "string"
                         }
                       },
                       required: ["hello"],
                       title: "HelloWorld",
                       type: "object"
                     },
                     "Math" => %OpenAPI.V3.Schema{
                       example: %{"result" => 13},
                       properties: %{
                         "result" => %OpenAPI.V3.Schema{
                           example: nil,
                           properties: nil,
                           required: [],
                           title: nil,
                           type: "integer"
                         }
                       },
                       required: ["result"],
                       title: "Math",
                       type: "object"
                     }
                   },
                   security_schemes: %{
                     "httpBearer" => %OpenAPI.V3.SecuritySchema{scheme: "bearer", type: "http"}
                   }
                 },
                 info: %OpenAPI.V3.Info{
                   contact: %OpenAPI.V3.Contact{email: nil, name: nil, url: nil},
                   description: nil,
                   license: nil,
                   terms_of_service: nil,
                   title: "OpenAPI Example API Server",
                   version: "1.0"
                 },
                 openapi: "3.0.0",
                 paths: %{
                   "/" => %OpenAPI.V3.PathItem{
                     description: nil,
                     get: %OpenAPI.V3.Operation{
                       description: nil,
                       external_docs: nil,
                       operation_id: "HelloWorld",
                       parameters: [],
                       request_body: nil,
                       responses: %{
                         "200" => %OpenAPI.V3.Response{
                           content: %{
                             "application/json" => %OpenAPI.V3.MediaType{
                               example: %{"hello" => "world"},
                               examples: nil,
                               schema: %OpenAPI.V3.Reference{
                                 ref: "#/components/schemas/HelloWorld"
                               }
                             }
                           },
                           description: ""
                         }
                       },
                       summary: "Hello World",
                       tags: ["Misc"]
                     },
                     post: nil,
                     ref: nil,
                     summary: nil
                   },
                   "/math" => %OpenAPI.V3.PathItem{
                     description: nil,
                     get: nil,
                     post: %OpenAPI.V3.Operation{
                       description: nil,
                       external_docs: nil,
                       operation_id: "Math",
                       parameters: [
                         %OpenAPI.V3.Parameter{
                           allow_empty_value: nil,
                           deprecated: nil,
                           description: "",
                           in: :header,
                           name: "Content-Type",
                           required: true
                         }
                       ],
                       request_body: %OpenAPI.V3.RequestBody{
                         content: %{
                           "application/x-www-form-urlencoded" => %OpenAPI.V3.MediaType{
                             example: nil,
                             examples: nil,
                             schema: %OpenAPI.V3.Schema{
                               example: nil,
                               properties: %{
                                 "lhs" => %OpenAPI.V3.Schema{
                                   example: 5,
                                   properties: nil,
                                   required: [],
                                   title: nil,
                                   type: "integer"
                                 },
                                 "operation" => %OpenAPI.V3.Schema{
                                   example: "add",
                                   properties: nil,
                                   required: [],
                                   title: nil,
                                   type: "string"
                                 },
                                 "rhs" => %OpenAPI.V3.Schema{
                                   example: 8,
                                   properties: nil,
                                   required: [],
                                   title: nil,
                                   type: "integer"
                                 }
                               },
                               required: ["lhs", "rhs", "operation"],
                               title: nil,
                               type: "object"
                             }
                           }
                         },
                         description: nil
                       },
                       responses: %{
                         "200" => %OpenAPI.V3.Response{
                           content: %{
                             "application/json" => %OpenAPI.V3.MediaType{
                               example: %{"result" => 13},
                               examples: nil,
                               schema: %OpenAPI.V3.Reference{ref: "#/components/schemas/Math"}
                             }
                           },
                           description: ""
                         }
                       },
                       summary: "Math",
                       tags: ["Misc"]
                     },
                     ref: nil,
                     summary: nil
                   }
                 },
                 servers: [
                   %OpenAPI.V3.Server{
                     description: nil,
                     url: "http://localhost:8880",
                     variables: %{}
                   }
                 ]
               } = document
    end
  end

  describe "client definition" do
    defmodule ExampleAPIClient do
      use OpenAPI.Client, document_path: "support/example_api_server/open_api_document.json"
    end

    test "should define modules for each path" do
      assert module_exists?(ExampleAPIClient.Paths)
      assert module_exists?(ExampleAPIClient.Paths.Root)
      assert module_exists?(ExampleAPIClient.Paths.Math)
    end

    test "path modules should have functions for each defined operation" do
      assert function_exists?(ExampleAPIClient.Paths.Root, {:get, 0})
      assert function_exists?(ExampleAPIClient.Paths.Math, {:post, 1})
    end
  end

  defp module_exists?(module) do
    match?({:module, _}, Code.ensure_compiled(module))
  end

  defp function_exists?(module, {name, arity}) do
    function_exported?(module, name, arity)
  end
end

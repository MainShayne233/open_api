defmodule OpenAPITest do
  use ExUnit.Case

  setup_all do
    Tesla.Mock.mock_global(fn
      %Tesla.Env{url: "https://api.mock.com/health_check"} ->
        %Tesla.Env{status: 200, body: "healthy!"}

      %Tesla.Env{url: "https://api.mock.com/users"} ->
        %Tesla.Env{status: 200, body: "[{\"username\":\"jane\"}]"}
    end)

    :ok
  end

  defmodule MockAPI do
    use OpenAPI,
      json_decoder: &Jason.decode/1,
      schema: %{
        "servers" => [%{"url" => "https://api.mock.com"}],
        "paths" => %{
          "/health_check" => %{
            "get" => %{"responses" => %{"200" => %{"content" => %{"text/plain" => %{}}}}}
          },
          "/users" => %{
            "get" => %{
              "responses" => %{
                "200" => %{
                  "content" => %{
                    "application/json" => %{
                      "schema" => %{
                        "type" => "array",
                        "items" => %{
                          "type" => "object",
                          "properties" => %{
                            "username" => %{"type" => "string"}
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
  end

  describe "using/2" do
    test "should generate the API" do
      assert Code.ensure_compiled?(__MODULE__.MockAPI)
    end

    test "should generate the /health_check path code" do
      assert {:ok, "healthy!"} =
               __MODULE__.MockAPI.HealthCheck.Get.make_request(tesla_adapter: Tesla.Mock)
    end

    test "should generate the /users path code" do
      assert {:ok, [%OpenAPITest.MockAPI.Users.Get.Response.Status200.Item{username: "jane"}]} =
               __MODULE__.MockAPI.Users.Get.make_request(tesla_adapter: Tesla.Mock)
    end
  end
end

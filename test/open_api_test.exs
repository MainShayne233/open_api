defmodule OpenAPITest do
  use ExUnit.Case

  setup_all do
    defmodule MockAPI do
      use OpenAPI,
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
                            "proprties" => %{
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

    Tesla.Mock.mock_global(fn
      %Tesla.Env{url: "https://api.mock.com/health_check"} ->
        %Tesla.Env{status: 200, body: "healthy!"}
    end)

    :ok
  end

  describe "using/2" do
    test "should generate the API" do
      assert Code.ensure_compiled?(__MODULE__.MockAPI)
    end

    test "should generate the /health_check path code" do
      assert {:ok, "healthy!"} = __MODULE__.MockAPI.HealthCheck.Get.make_request(tesla_adapter: Tesla.Mock)
    end
  end
end

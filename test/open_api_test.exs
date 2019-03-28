defmodule OpenAPITest do
  use ExUnit.Case

  setup_all do
    Tesla.Mock.mock_global(fn
      %Tesla.Env{url: "https://api.mock.com/health_check"} ->
        %Tesla.Env{status: 200, body: "healthy!"}
    end)

    :ok
  end

  describe "using/2" do
    test "should generate the API" do
      defmodule MockAPI do
        use OpenAPI,
          schema: %{
            "servers" => [%{"url" => "https://api.mock.com"}],
            "paths" => %{
              "/health_check" => %{
                "get" => %{}
              }
            }
          }
      end

      assert {:ok, _} = __MODULE__.MockAPI.HealthCheck.Get.make_request(tesla_adapter: Tesla.Mock)
    end
  end
end

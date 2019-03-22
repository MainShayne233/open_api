defmodule OpenAPITest do
  use ExUnit.Case

  setup_all do
    defmodule MockAPI do
      use OpenAPI,
        schema: %{
          "servers" => [%{"url" => "https://api.mock.com"}],
          "paths" => %{
            "/users/index" => %{}
          }
        }
    end

    :ok
  end

  describe "using/2" do
    test "should generate the API" do
      assert Code.ensure_compiled?(__MODULE__.MockAPI.Users.Index)
    end
  end
end

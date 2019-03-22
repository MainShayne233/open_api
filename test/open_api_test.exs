defmodule OpenAPITest do
  use ExUnit.Case

  setup_all do
    {:module, api_module, _, _} =
      defmodule MyAPI do
      end

    %{module: api_module}
  end

  describe "using/2" do
    test "should generate the API", %{module: module} do
      assert module
    end
  end
end

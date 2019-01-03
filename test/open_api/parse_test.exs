defmodule OpenAPI.ParseTest do
  use ExUnit.Case

  setup do
    json_spec_file = {"test/support/api_specs/tax_jar_open_api.json", :json}

    %{json_spec_file: json_spec_file}
  end

  describe "parse_spec_file/1" do
    test "should properly parse a json spec file", %{json_spec_file: json_spec_file} do
      assert {:ok, %OpenAPI.Spec{} = spec} = OpenAPI.Parse.parse_spec_file(json_spec_file)

      assert spec.openapi == "3.0.1"

      [first_path | _] = spec.paths

      assert first_path.name == "/v2/taxes"

      [first_action | _] = first_path.actions

      assert first_action.type == :post
    end
  end
end

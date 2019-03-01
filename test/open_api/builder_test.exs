defmodule OpenAPI.BuilderTest do
  use ExUnit.Case

  setup do
    schema =
      "test/support/schemas/tax_jar.json"
      |> File.read!()
      |> Jason.decode!()
      |> OpenAPI.Parser.parse_schema()

    %{schema: schema}
  end

  describe "generate_api/2" do
    test "should produce the expected AST", %{schema: schema} do
      assert ast = OpenAPI.Builder.generate_api(schema, MyApp.MyAPI)

      module_string =
        quote do
          defmodule(MyApp.MyAPI) do
            unquote(ast)
          end
        end
        |> Macro.to_string()
        |> Code.format_string!()

      IO.puts(module_string)
    end
  end
end

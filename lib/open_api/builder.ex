defmodule OpenAPI.Builder do
  alias OpenAPI.Schema

  defmacro __before_compile__(_env) do
    params = Module.get_attribute(__CALLER__.module, :params)
    Module.delete_attribute(__CALLER__.module, :params)

    raw_schema = Keyword.fetch!(params, :schema)

    %Schema{} = schema = OpenAPI.Parser.parse_schema(raw_schema)

    generate_api(schema, __CALLER__.module)
  end

  @doc """
  Generates the AST for the API defined by the schema.
  """
  @spec generate_api(Schema.t(), parent_module() :: module()) :: OpenAPI.ast()
  def generate_api(schema, parent_module) do
    quote do
      unquote(define_module_doc(schema))

      unquote(define_domain(schema))

      unquote_splicing(define_path_modules(schema, parent_module))
    end
  end

  @spec define_path_modules(Schema.t(), parent_module :: module()) :: [OpenAPI.ast()]
  defp define_path_modules(%Schema{paths: %{} = paths}, parent_module) do
    Enum.map(paths, fn {path_name, %Schema.PathItem{} = path_item} ->
      define_path_module(path_name, path_item, parent_module)
    end)
  end

  @spec define_path_module(
          path_name :: String.t(),
          Schema.PathItem.t(),
          parent_module :: module()
        ) :: OpenAPI.ast()
  defp define_path_module(path_name, %Schema.PathItem{} = path_item, parent_module) do
    path_module_name = path_name_to_module_name(parent_module, path_name)

    quote do
      defmodule unquote(path_module_name) do
        (unquote_splicing(define_operation_modules(path_module_name, path_item)))
      end
    end
  end

  @spec define_operation_modules(parent_module :: module(), Schema.PathItem.t()) :: [
          OpenAPI.ast()
        ]
  defp define_operation_modules(parent_module, %Schema.PathItem{} = path_item) do
    Schema.PathItem.all_operation_types()
    |> Enum.filter(&Map.get(path_item, &1))
    |> Enum.map(fn operation_type ->
      module_name = module_name(parent_module, [Atom.to_string(operation_type)])

      quote do
        defmodule unquote(module_name) do
          unquote(define_request_body_module(module_name, Map.get(path_item, operation_type)))
        end
      end
    end)
  end

  @spec define_request_body_module(parent_module :: module(), Schema.Operation.t()) ::
          OpenAPI.ast()
  defp define_request_body_module(parent_module, %Schema.Operation{} = operation) do
    module_name = module_name(parent_module, ["RequestBody"])

    quote do
      defmodule unquote(module_name) do
        @moduledoc unquote(operation.description || false)

        unquote(define_typed_struct_for_operation(module_name, operation))
      end
    end
  end

  @spec define_typed_struct_for_operation(parent_module :: module(), Schema.Operation.t()) ::
          OpenAPI.ast()
  defp define_typed_struct_for_operation(parent_module, %Schema.Operation{
         request_body: %Schema.RequestBody{
           content: %{
             "application/json" => %Schema.RequestPayload{
               schema: %Schema.DataSchema{} = data_schema
             }
           }
         }
       }) do
    quote do
      unquote(define_typed_struct(parent_module, data_schema))
    end
  end

  defp define_typed_struct_for_operation(_parent_module, %Schema.Operation{}) do
    quote do
      def need_to_define do
        :need_to_define
      end
    end
  end

  @spec define_typed_struct(parent_module :: module(), Schema.DataSchema.t()) :: OpenAPI.ast()
  defp define_typed_struct(parent_module, %Schema.DataSchema{
         type: :object,
         properties: %{} = properties
       }) do
    quote do
      use TypedStruct

      typedstruct do
        (unquote_splicing(Enum.map(properties, &define_typed_struct_field(parent_module, &1))))
      end

      (unquote_splicing(
         properties
         |> Enum.map(&define_nested_structs(parent_module, &1))
         |> Enum.reject(&is_nil/1)
       ))
    end
  end

  @spec define_nested_structs(
          parent_module :: module(),
          {field_name :: String.t(), Schema.DataSchema.t()}
        ) :: OpenAPI.ast()
  defp define_nested_structs(
         parent_module,
         {field_name, %Schema.DataSchema{type: :array, items: %Schema.DataSchema{} = item_schema}}
       ) do
    module_name = module_name(parent_module, [field_name, "item"])

    quote do
      defmodule unquote(module_name) do
        unquote(define_typed_struct(parent_module, item_schema))
      end
    end
  end

  defp define_nested_structs(_parent_module, _field_key_value) do
    nil
  end

  @spec define_typed_struct_field(
          parent_module :: module(),
          {field_name :: String.t(), Schema.DataSchema.t()}
        ) :: OpenAPI.ast()
  defp define_typed_struct_field(parent_module, {field_name, field_schema}) do
    quote do
      field(
        unquote(String.to_atom(field_name)),
        unquote(typed_struct_field_type(parent_module, field_name, field_schema))
      )
    end
  end

  @spec typed_struct_field_type(
          parent_module :: module(),
          field_name :: String.t(),
          Schema.DataSchema.t()
        ) :: OpenAPI.ast()
  defp typed_struct_field_type(parent_module, field_name, %Schema.DataSchema{
         type: :array,
         items: %Schema.DataSchema{} = item_schema
       }) do
    item_type =
      case item_schema.type do
        :object ->
          quote do
            unquote(module_name(parent_module, [field_name, "item"])).t()
          end

        _other ->
          typed_struct_field_type(parent_module, field_name, item_schema)
      end

    quote do
      [unquote(item_type)]
    end
  end

  defp typed_struct_field_type(parent_module, field_name, %Schema.DataSchema{
         type: :object,
         properties: %{} = _properties
       }) do
    quote do
      unquote(module_name(parent_module, [field_name])).t()
    end
  end

  defp typed_struct_field_type(_parent_module, _field_name, %Schema.DataSchema{type: :string}) do
    quote do
      String.t()
    end
  end

  defp typed_struct_field_type(_parent_module, _field_name, %Schema.DataSchema{type: :integer}) do
    quote do
      integer()
    end
  end

  defp typed_struct_field_type(_parent_module, _field_name, %Schema.DataSchema{type: :float}) do
    quote do
      float()
    end
  end

  defp typed_struct_field_type(_parent_module, _field_name, %Schema.DataSchema{type: :number}) do
    quote do
      number()
    end
  end

  @spec path_name_to_module_name(parent_module :: module(), path_name :: String.t()) :: module()
  defp path_name_to_module_name(parent_module, path_name)
       when is_atom(parent_module)
       when is_binary(path_name) do
    path_name
    |> Path.split()
    |> Enum.drop(1)
    |> (&module_name(parent_module, &1)).()
  end

  @spec module_name(parent_module :: module(), path :: [String.t()]) :: module()
  defp module_name(parent_module, path) do
    [Atom.to_string(parent_module) | path]
    |> Enum.map(&Macro.camelize/1)
    |> Enum.join(".")
    |> String.to_atom()
  end

  @spec define_module_doc(Schema.t()) :: OpenAPI.ast()
  defp define_module_doc(%Schema{
         info: %Schema.Info{title: title, description: description, version: version}
       })
       when is_binary(title) and is_binary(description) and is_binary(version) do
    doc = """
    #{title} - #{version}

    #{description}
    """

    quote do
      @moduledoc unquote(doc)
    end
  end

  defp define_module_doc(%Schema{}) do
    quote do
      @moduledoc false
    end
  end

  defp define_domain(%Schema{servers: [%Schema.Server{url: url}]}) when is_binary(url) do
    quote do
      @domain unquote(url)
    end
  end

  defp define_domain(%Schema{}) do
    raise "schema.servers must be a single-item list w/ a single %Schema.Server{}"
  end
end

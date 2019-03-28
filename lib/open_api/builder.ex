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
        @path_name unquote(path_name)

        @spec path_name :: String.t()
        def path_name, do: @path_name

        (unquote_splicing(define_operation_modules(path_module_name, path_item)))

        defdelegate domain, to: unquote(parent_module)
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

      operation = Map.get(path_item, operation_type)

      quote do
        defmodule unquote(module_name) do
          unquote(define_request_body_module(module_name, operation))

          unquote(define_operation_functions(parent_module, operation_type))

          defdelegate domain, to: unquote(parent_module)
          defdelegate path_name, to: unquote(parent_module)
        end
      end
    end)
  end

  @spec define_operation_functions(
          parent_module :: module(),
          operation_type :: Schema.PathItem.operation_type()
        ) :: OpenAPI.ast()
  defp define_operation_functions(parent_module, operation_type) when is_atom(operation_type) do
    quote do
      unquote(define_operation_middleware_function(parent_module, operation_type))
      unquote(define_operation_adapter_function(parent_module, operation_type))
      unquote(define_operation_client_function(parent_module, operation_type))
      unquote(define_operation_path_function(parent_module, operation_type))
      unquote(define_operation_make_request_function(parent_module, operation_type))
      unquote(define_operation_handle_response_function(parent_module, operation_type))
      unquote(define_operation_decode_response_function(parent_module, operation_type))
    end
  end

  @spec define_operation_middleware_function(
          parent_module :: module(),
          Schema.PathItem.operation_type()
        ) :: OpenAPI.ast()
  defp define_operation_middleware_function(_parent_module, _operation_type) do
    quote do
      @spec middleware(options :: Keyword.t()) :: Tesla.Client.middleware()
      def middleware(options \\ []) do
        []
      end
    end
  end

  @spec define_operation_adapter_function(
          parent_module :: module(),
          Schema.PathItem.operation_type()
        ) :: OpenAPI.ast()
  defp define_operation_adapter_function(_parent_module, _operation_type) do
    quote do
      @spec adapter(options :: Keyword.t()) :: Tesla.Client.adapter()
      def adapter(options \\ []) do
        Keyword.get(options, :tesla_adapter, Tesla.Adapter.Httpc)
      end
    end
  end

  @spec define_operation_client_function(
          parent_module :: module(),
          Schema.PathItem.operation_type()
        ) :: OpenAPI.ast()
  defp define_operation_client_function(_parent_module, _operation_type) do
    quote do
      @spec client(options :: Keyword.t()) :: Tesla.Client.t()
      def client(options \\ []) do
        Tesla.client(middleware(options), adapter(options))
      end
    end
  end

  @spec define_operation_path_function(
          parent_module :: module(),
          Schema.PathItem.operation_type()
        ) :: OpenAPI.ast()
  defp define_operation_path_function(_parent_module, _operation_type) do
    quote do
      @spec path(options :: Keyword.t()) :: any()
      def path(options \\ []) do
        Path.join(domain(), path_name())
      end
    end
  end

  @spec define_operation_make_request_function(
          parent_module :: module(),
          Schema.PathItem.operation_type()
        ) :: OpenAPI.ast()
  defp define_operation_make_request_function(_parent_module, operation_type) do
    quote do
      @spec make_request(options :: Keyword.t()) :: any()
      def make_request(options \\ []) do
        Tesla
        |> apply(unquote(operation_type), [client(options), path(options)])
        |> handle_response(options)
      end
    end
  end

  @spec define_operation_handle_response_function(
          parent_module :: module(),
          Schema.PathItem.operation_type()
        ) :: OpenAPI.ast()
  defp define_operation_handle_response_function(_parent_module, _operation_type) do
    quote do
      @spec handle_response(Tesla.Env.result()) :: any()
      defp handle_response(response, options \\ []) do
        with {:ok, %Tesla.Env{} = response_env} <- response do
          if Keyword.get(options, :decode_response, true) do
            decode_response(response_env)
          else
            response_env
          end
        end
      end
    end
  end

  @spec define_operation_decode_response_function(
          parent_module :: module(),
          Schema.PathItem.operation_type()
        ) :: OpenAPI.ast()
  defp define_operation_decode_response_function(_parent_module, _operation_type) do
    quote do
      @spec decode_response(Tesla.Env.result()) :: any()
      defp decode_response(%Tesla.Env{body: body}, options \\ []) do
        {:ok, body}
      end
    end
  end

  @spec define_request_body_module(parent_module :: module(), Schema.Operation.t()) ::
          OpenAPI.ast()
  defp define_request_body_module(parent_module, %Schema.Operation{} = operation) do
    if operation.request_body do
      module_name = module_name(parent_module, ["RequestBody"])

      quote do
        defmodule unquote(module_name) do
          @moduledoc unquote(operation.description || false)

          unquote(define_typed_struct_for_operation(module_name, operation))
        end
      end
    else
      nil
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

  defp define_typed_struct_for_operation(parent_module, %Schema.Operation{
         parameters: [_ | _] = parameters
       }) do
    data_schema = convert_parameters_to_data_schema(parameters)

    quote do
      unquote(define_typed_struct(parent_module, data_schema))
    end
  end

  @spec convert_parameters_to_data_schema([Schema.Parameter.t()]) :: Schema.DataSchema.t()
  defp convert_parameters_to_data_schema(parameters) do
    Enum.reduce(parameters, %Schema.DataSchema{type: :object, properties: %{}}, fn
      %Schema.Parameter{in: :query, name: name, schema: schema}, data_schema ->
        updated_properites = Map.put(data_schema.properties, name, schema)
        %Schema.DataSchema{data_schema | properties: updated_properites}
    end)
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

      @spec domain :: String.t()
      def domain, do: @domain
    end
  end

  defp define_domain(%Schema{}) do
    raise "schema.servers must be a single-item list w/ a single %Schema.Server{}"
  end
end

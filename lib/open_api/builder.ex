defmodule OpenAPI.Builder do
  alias OpenAPI.Schema

  @type json_decoder :: (json :: String.t() -> {:ok, term()} | {:error, term()})

  @type t :: %__MODULE__{
          schema: Schema.t(),
          host_module: module(),
          parent_module: module(),
          json_decoder: json_decoder()
        }

  defstruct [
    :schema,
    :host_module,
    :parent_module,
    :json_decoder
  ]

  alias OpenAPI.Builder

  defmacro __before_compile__(_env) do
    params = Module.get_attribute(__CALLER__.module, :params)
    Module.delete_attribute(__CALLER__.module, :params)

    raw_schema = Keyword.fetch!(params, :schema)
    json_decoder = Keyword.fetch!(params, :json_decoder)

    %Schema{} = schema = OpenAPI.Parser.parse_schema(raw_schema)

    generate_api(schema, __CALLER__.module, json_decoder)
  end

  @doc """
  Generates the AST for the API defined by the schema.
  """
  @spec generate_api(Schema.t(), parent_module :: module(), json_decoder()) :: OpenAPI.ast()
  def generate_api(%Schema{} = schema, parent_module, json_decoder) do
    builder = %Builder{
      schema: schema,
      host_module: parent_module,
      parent_module: parent_module,
      json_decoder: json_decoder
    }

    quote do
      unquote(define_domain(builder))

      unquote_splicing(define_path_modules(builder))
    end
  end

  @spec define_path_modules(Builder.t()) :: [OpenAPI.ast()]
  defp define_path_modules(%Builder{schema: %Schema{paths: %{} = paths}} = builder) do
    Enum.map(paths, fn {path_name, %Schema.PathItem{} = path_item} ->
      define_path_module(builder, path_name, path_item)
    end)
  end

  @spec define_path_module(
          Builder.t(),
          path_name :: String.t(),
          Schema.PathItem.t()
        ) :: OpenAPI.ast()
  defp define_path_module(
         %Builder{parent_module: parent_module} = builder,
         path_name,
         %Schema.PathItem{} = path_item
       ) do
    path_module_name = path_name_to_module_name(parent_module, path_name)

    quote do
      defmodule unquote(path_module_name) do
        @path_name unquote(path_name)

        @spec path_name :: String.t()
        def path_name, do: @path_name

        (unquote_splicing(
           define_operation_modules(
             %Builder{builder | parent_module: path_module_name},
             path_item
           )
         ))

        defdelegate domain, to: unquote(parent_module)
      end
    end
  end

  @spec define_operation_modules(Builder.t(), Schema.PathItem.t()) :: [
          OpenAPI.ast()
        ]
  defp define_operation_modules(
         %Builder{parent_module: parent_module} = builder,
         %Schema.PathItem{} = path_item
       ) do
    Schema.PathItem.all_operation_types()
    |> Enum.filter(&Map.get(path_item, &1))
    |> Enum.map(fn operation_type ->
      module_name = module_name(parent_module, [Atom.to_string(operation_type)])

      operation = Map.get(path_item, operation_type)

      quote do
        defmodule unquote(module_name) do
          unquote(
            define_request_body_module(%Builder{builder | parent_module: module_name}, operation)
          )

          unquote(
            define_response_module(%Builder{builder | parent_module: module_name}, operation)
          )

          unquote(define_operation_functions(builder, operation_type))

          defdelegate domain, to: unquote(parent_module)
          defdelegate path_name, to: unquote(parent_module)
        end
      end
    end)
  end

  @spec define_response_module(Builder.t(), Schema.Operation.t()) :: OpenAPI.ast()
  defp define_response_module(
         %Builder{parent_module: parent_module} = builder,
         %Schema.Operation{} = operation
       ) do
    module_name = module_name(parent_module, ["Response"])

    response_status_modules =
      Enum.map(operation.responses, fn {status_code, response} ->
        define_response_module(
          %Builder{builder | parent_module: module_name},
          status_code,
          response
        )
      end)

    quote do
      defmodule unquote(module_name) do
        (unquote_splicing(response_status_modules))
      end
    end
  end

  @spec define_response_module(Builder.t(), status_code :: String.t(), Schema.Response.t()) ::
          OpenAPI.ast()
  defp define_response_module(
         %Builder{parent_module: parent_module} = builder,
         status_code,
         %Schema.Response{} = response
       ) do
    module_name = module_name(parent_module, ["Status#{status_code}"])

    quote do
      defmodule unquote(module_name) do
        unquote(
          define_typed_struct_for_response(
            %Builder{builder | parent_module: module_name},
            response
          )
        )

        unquote(
          define_decode_response_function(
            %Builder{builder | parent_module: module_name},
            response
          )
        )
      end
    end
  end

  @spec define_typed_struct_for_response(Builder.t(), Schema.Response.t()) :: OpenAPI.ast()
  defp define_typed_struct_for_response(%Builder{} = builder, %Schema.Response{
         content: %{
           "application/json" => %Schema.ResponsePayload{
             schema: %Schema.DataSchema{} = data_schema
           }
         }
       }) do
    quote do
      unquote(define_typed_struct(builder, data_schema))
    end
  end

  defp define_typed_struct_for_response(%Builder{} = builder, %Schema.Response{}) do
    quote do
      unquote(
        define_typed_struct(builder, %Schema.DataSchema{
          type: :object,
          properties: %{"text" => %Schema.DataSchema{type: :string}}
        })
      )
    end
  end

  @spec define_decode_response_function(Builder.t(), Schema.Response.t()) :: OpenAPI.ast()
  defp define_decode_response_function(%Builder{} = builder, %Schema.Response{
         content: %{"application/json" => _}
       }) do
    quote do
      def decode_response(response) do
        with {:ok, decoded_json} <- unquote(builder.json_decoder).(response) do
          do_decode(decoded_json, [])
        end
      end

      defp do_decode(%{} = response, namespace) do
        params = for {key, value} <- response, do: {String.to_atom(key), value}

        {:ok, struct!(resolve_module(namespace), params)}
      end

      defp do_decode(response, namespace) when is_list(response) do
        item_namespace = namespace ++ ["item"]

        Enum.reduce_while(response, [], fn item, items ->
          case do_decode(item, item_namespace) do
            {:ok, item} ->
              {:cont, [item | items]}

            {:error, error} ->
              {:halt, {:error, error}}
          end
        end)
        |> case do
          items when is_list(items) ->
            {:ok, items}

          {:error, error} ->
            {:error, error}
        end
      end

      defp resolve_module(namespace) do
        ["#{__MODULE__}" | Enum.map(namespace, &Macro.camelize("#{&1}"))]
        |> Enum.join(".")
        |> String.to_atom()
      end
    end
  end

  defp define_decode_response_function(%Builder{}, %Schema.Response{}) do
    quote do
      def decode_response(response) do
        {:ok, response}
      end
    end
  end

  @spec define_operation_functions(
          Builder.t(),
          operation_type :: Schema.PathItem.operation_type()
        ) :: OpenAPI.ast()
  defp define_operation_functions(
         %Builder{},
         operation_type
       )
       when is_atom(operation_type) do
    quote do
      unquote(define_operation_middleware_function())
      unquote(define_operation_adapter_function())
      unquote(define_operation_client_function())
      unquote(define_operation_path_function())
      unquote(define_operation_make_request_function(operation_type))
      unquote(define_operation_handle_response_function())
      unquote(define_operation_decode_response_function())
    end
  end

  @spec define_operation_middleware_function :: OpenAPI.ast()
  defp define_operation_middleware_function do
    quote do
      @spec middleware(options :: Keyword.t()) :: Tesla.Client.middleware()
      def middleware(options \\ []) do
        []
      end
    end
  end

  @spec define_operation_adapter_function :: OpenAPI.ast()
  defp define_operation_adapter_function do
    quote do
      @spec adapter(options :: Keyword.t()) :: Tesla.Client.adapter()
      def adapter(options \\ []) do
        Keyword.get(options, :tesla_adapter, Tesla.Adapter.Httpc)
      end
    end
  end

  @spec define_operation_client_function :: OpenAPI.ast()
  defp define_operation_client_function do
    quote do
      @spec client(options :: Keyword.t()) :: Tesla.Client.t()
      def client(options \\ []) do
        Tesla.client(middleware(options), adapter(options))
      end
    end
  end

  @spec define_operation_path_function :: OpenAPI.ast()
  defp define_operation_path_function do
    quote do
      @spec path(options :: Keyword.t()) :: any()
      def path(options \\ []) do
        Path.join(domain(), path_name())
      end
    end
  end

  @spec define_operation_make_request_function(Schema.PathItem.operation_type()) :: OpenAPI.ast()
  defp define_operation_make_request_function(operation_type) do
    quote do
      @spec make_request(options :: Keyword.t()) :: any()
      def make_request(options \\ []) do
        Tesla
        |> apply(unquote(operation_type), [client(options), path(options)])
        |> handle_response(options)
      end
    end
  end

  @spec define_operation_handle_response_function :: OpenAPI.ast()
  defp define_operation_handle_response_function do
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

  @spec define_operation_decode_response_function :: OpenAPI.ast()
  defp define_operation_decode_response_function do
    quote do
      @spec decode_response(Tesla.Env.result()) :: any()
      defp decode_response(%Tesla.Env{status: status_code, body: body}, options \\ []) do
        apply(:"#{__MODULE__}.Response.Status#{status_code}", :decode_response, [body])
      end
    end
  end

  @spec define_request_body_module(Builder.t(), Schema.Operation.t()) :: OpenAPI.ast()
  defp define_request_body_module(
         %Builder{parent_module: parent_module} = builder,
         %Schema.Operation{} = operation
       ) do
    if operation.request_body do
      module_name = module_name(parent_module, ["RequestBody"])

      quote do
        defmodule unquote(module_name) do
          @moduledoc unquote(operation.description || false)

          unquote(
            define_typed_struct_for_operation(
              %Builder{builder | parent_module: module_name},
              operation
            )
          )
        end
      end
    else
      nil
    end
  end

  @spec define_typed_struct_for_operation(Builder.t(), Schema.Operation.t()) :: OpenAPI.ast()
  defp define_typed_struct_for_operation(%Builder{} = builder, %Schema.Operation{
         request_body: %Schema.RequestBody{
           content: %{
             "application/json" => %Schema.RequestPayload{
               schema: %Schema.DataSchema{} = data_schema
             }
           }
         }
       }) do
    quote do
      unquote(define_typed_struct(builder, data_schema))
    end
  end

  defp define_typed_struct_for_operation(%Builder{} = builder, %Schema.Operation{
         parameters: [_ | _] = parameters
       }) do
    data_schema = convert_parameters_to_data_schema(parameters)

    quote do
      unquote(define_typed_struct(builder, data_schema))
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

  @spec define_typed_struct(Builder.t(), Schema.DataSchema.t()) :: OpenAPI.ast()
  defp define_typed_struct(%Builder{} = builder, %Schema.DataSchema{
         type: :object,
         properties: %{} = properties
       }) do
    quote do
      use TypedStruct

      typedstruct do
        (unquote_splicing(Enum.map(properties, &define_typed_struct_field(builder, &1))))
      end

      (unquote_splicing(
         properties
         |> Enum.map(&define_nested_structs(builder, &1))
         |> Enum.reject(&is_nil/1)
       ))
    end
  end

  defp define_typed_struct(
         %Builder{parent_module: parent_module} = builder,
         %Schema.DataSchema{
           type: :array,
           items: item_data_schema
         }
       ) do
    quote do
      use TypedStruct

      typedstruct do
        field(:items, [unquote(module_name(parent_module, ["Item"])).t()])
      end

      unquote(define_nested_structs(builder, {"Item", item_data_schema}))
    end
  end

  @spec define_nested_structs(
          Builder.t(),
          {field_name :: String.t(), Schema.DataSchema.t()}
        ) :: OpenAPI.ast() | nil
  defp define_nested_structs(
         %Builder{parent_module: parent_module} = builder,
         {field_name, %Schema.DataSchema{type: :array, items: %Schema.DataSchema{} = item_schema}}
       ) do
    module_name = module_name(parent_module, [field_name, "item"])

    quote do
      defmodule unquote(module_name) do
        unquote(define_typed_struct(builder, item_schema))
      end
    end
  end

  defp define_nested_structs(
         %Builder{parent_module: parent_module} = builder,
         {field_name, %Schema.DataSchema{type: :object} = schema}
       ) do
    module_name = module_name(parent_module, [field_name])

    quote do
      defmodule unquote(module_name) do
        unquote(define_typed_struct(%Builder{builder | parent_module: module_name}, schema))
      end
    end
  end

  defp define_nested_structs(_parent_module, _field_key_value) do
    nil
  end

  @spec define_typed_struct_field(
          Builder.t(),
          {field_name :: String.t(), Schema.DataSchema.t()}
        ) :: OpenAPI.ast()
  defp define_typed_struct_field(%Builder{} = builder, {field_name, field_schema}) do
    quote do
      field(
        unquote(String.to_atom(field_name)),
        unquote(typed_struct_field_type(builder, field_name, field_schema))
      )
    end
  end

  @spec typed_struct_field_type(
          Builder.t(),
          field_name :: String.t(),
          Schema.DataSchema.t()
        ) :: OpenAPI.ast()
  defp typed_struct_field_type(
         %Builder{parent_module: parent_module} = builder,
         field_name,
         %Schema.DataSchema{
           type: :array,
           items: %Schema.DataSchema{} = item_schema
         }
       ) do
    item_type =
      case item_schema.type do
        :object ->
          quote do
            unquote(module_name(parent_module, [field_name, "item"])).t()
          end

        _other ->
          typed_struct_field_type(builder, field_name, item_schema)
      end

    quote do
      [unquote(item_type)]
    end
  end

  defp typed_struct_field_type(
         %Builder{parent_module: parent_module},
         field_name,
         %Schema.DataSchema{
           type: :object,
           properties: %{} = _properties
         }
       ) do
    quote do
      unquote(module_name(parent_module, [field_name])).t()
    end
  end

  defp typed_struct_field_type(_builder, _field_name, %Schema.DataSchema{type: :string}) do
    quote do
      String.t()
    end
  end

  defp typed_struct_field_type(_builder, _field_name, %Schema.DataSchema{type: :integer}) do
    quote do
      integer()
    end
  end

  defp typed_struct_field_type(_builder, _field_name, %Schema.DataSchema{type: :float}) do
    quote do
      float()
    end
  end

  defp typed_struct_field_type(_builder, _field_name, %Schema.DataSchema{type: :number}) do
    quote do
      number()
    end
  end

  defp typed_struct_field_type(_builder, _field_name, %Schema.DataSchema{type: :boolean}) do
    quote do
      boolean()
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

  defp define_domain(%Builder{schema: %Schema{servers: [%Schema.Server{url: url}]}})
       when is_binary(url) do
    quote do
      @domain unquote(url)

      @spec domain :: String.t()
      def domain, do: @domain
    end
  end

  defp define_domain(%Builder{}) do
    raise "schema.servers must be a single-item list w/ a single %Schema.Server{}"
  end
end

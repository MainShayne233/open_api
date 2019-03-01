defmodule OpenAPI.Parser do
  @moduledoc """
  Parses a raw schema for eventual use by the builder.
  """
  use TypedStruct

  alias OpenAPI.{Parser, Schema}
  alias OpenAPI.Util.EnumUtil

  @type result :: {:ok, Parser.t()} | {:error, atom()}

  @operation_types [
    :get,
    :put,
    :post,
    :delete,
    :options,
    :head,
    :patch,
    :trace
  ]

  typedstruct do
    field(:raw_schema, map())
    field(:schema, Schema.t())
  end

  @doc """
  Walks the raw schema and produces a OpenAPI.Schema.t()
  """
  @spec parse_schema(raw_schema :: map()) :: {:ok, Schema.t()} | {:error, atom()}
  def parse_schema(%{} = raw_schema) do
    with {:ok, %Parser{schema: %Schema{} = schema}} <-
           EnumUtil.process_map(%Parser{schema: %Schema{}, raw_schema: raw_schema}, [
             &parse_info/1,
             &parse_servers/1,
             &parse_paths/1
           ]) do
      {:ok, schema}
    end
  end

  @spec parse_info(Parser.t()) :: result()
  defp parse_info(%Parser{schema: schema, raw_schema: raw_schema} = parser) do
    updated_schema = %Schema{
      schema
      | info: %Schema.Info{
          title: get_in(raw_schema, ["info", "title"]),
          description: get_in(raw_schema, ["info", "description"]),
          version: get_in(raw_schema, ["info", "version"])
        }
    }

    {:ok, %Parser{parser | schema: updated_schema}}
  end

  @spec parse_servers(Parser.t()) :: result()
  defp parse_servers(%Parser{schema: schema, raw_schema: raw_schema} = parser) do
    servers =
      raw_schema
      |> Map.get("servers", [])
      |> Enum.map(&%Schema.Server{url: Map.get(&1, "url")})

    updated_schema = %Schema{
      schema
      | servers: servers
    }

    {:ok, %Parser{parser | schema: updated_schema}}
  end

  @spec parse_paths(Parser.t()) :: result()
  defp parse_paths(%Parser{schema: schema, raw_schema: raw_schema} = parser) do
    paths =
      raw_schema
      |> Map.get("paths", %{})
      |> Enum.reduce(%{}, fn {path_name, raw_path_item}, path_mapping ->
        Map.put(path_mapping, path_name, parse_path_item(raw_path_item))
      end)

    updated_schema = %Schema{schema | paths: paths}

    {:ok, %Parser{parser | schema: updated_schema}}
  end

  @spec parse_path_item(raw_path_item :: map()) :: Schema.PathItem.t()
  defp parse_path_item(%{} = raw_path_item) do
    %Schema.PathItem{}
    |> Map.merge(parse_operations(raw_path_item))
  end

  @spec parse_operations(raw_path_item :: map()) :: %{
          required(operation_type :: atom()) => Schema.Operation.t()
        }
  defp parse_operations(%{} = raw_path_item) do
    Enum.reduce(@operation_types, %{}, fn operation_type, operations_mapping ->
      case Map.get(raw_path_item, Atom.to_string(operation_type)) do
        %{} = raw_operation ->
          Map.put(operations_mapping, operation_type, parse_operation(raw_operation))

        nil ->
          operations_mapping
      end
    end)
  end

  @spec parse_operation(raw_operation :: map()) :: Schema.Operation.t()
  defp parse_operation(raw_operation) do
    request_body =
      with %{} = raw_request_body <- Map.get(raw_operation, "requestBody") do
        parse_request_body(raw_request_body)
      end

    %Schema.Operation{
      description: Map.get(raw_operation, "description"),
      request_body: request_body
    }
  end

  @spec parse_request_body(raw_operation :: map()) :: Schema.RequestBody.t()
  defp parse_request_body(raw_operation) do
    content =
      raw_operation
      |> Map.get("content", %{})
      |> parse_payload_content()

    %Schema.RequestBody{
      description: Map.get(raw_operation, "description"),
      content: content
    }
  end

  @spec parse_payload_content(raw_content :: map()) :: %{
          required(media_type :: String.t()) => Schema.RequestPayload.t()
        }
  defp parse_payload_content(%{} = raw_content) do
    Enum.reduce(raw_content, %{}, fn {media_type, body}, content_mapping ->
      Map.put(content_mapping, media_type, parse_request_payload(body))
    end)
  end

  @spec parse_request_payload(raw_request_payload :: map()) :: Schema.RequestPayload.t()
  defp parse_request_payload(%{} = raw_request_payload) do
    schema =
      raw_request_payload
      |> Map.get("schema", %{})
      |> parse_data_schema()

    %Schema.RequestPayload{
      schema: schema
    }
  end

  @spec parse_data_schema(raw_schema :: map()) :: Schema.DataSchema.t()
  defp parse_data_schema(%{"type" => "object"} = raw_schema) do
    properties =
      with %{} = raw_properties <- Map.get(raw_schema, "properties") do
        parse_properties(raw_properties)
      end

    %Schema.DataSchema{
      type: :object,
      properties: properties
    }
  end

  defp parse_data_schema(%{"type" => "array"} = raw_schema) do
    items =
      with %{} = raw_items <- Map.get(raw_schema, "items") do
        parse_data_schema(raw_items)
      end

    %Schema.DataSchema{
      type: :array,
      items: items
    }
  end

  defp parse_data_schema(%{"type" => "integer"}) do
    %Schema.DataSchema{
      type: :integer
    }
  end

  defp parse_data_schema(%{"type" => "float"}) do
    %Schema.DataSchema{
      type: :float
    }
  end

  defp parse_data_schema(%{"type" => "number"}) do
    %Schema.DataSchema{
      type: :number
    }
  end

  defp parse_data_schema(%{"type" => "string"}) do
    %Schema.DataSchema{
      type: :string
    }
  end

  defp parse_data_schema(%{"type" => other}) do
    raise "Not supporting data schema type: #{other}"
  end

  defp parse_data_schema(%{}) do
    nil
  end

  @spec parse_properties(raw_properties :: map()) :: %{
          required(property_name :: String.t()) => Schema.DataSchema.t()
        }
  defp parse_properties(%{} = raw_properties) do
    Enum.reduce(raw_properties, %{}, fn {property_name, property_body}, property_mapping ->
      Map.put(property_mapping, property_name, parse_data_schema(property_body))
    end)
  end
end

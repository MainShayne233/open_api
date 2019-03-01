defmodule OpenAPI.Parser do
  @moduledoc """
  Parses a raw schema for eventual use by the builder.
  """
  use TypedStruct

  alias OpenAPI.{Parser, Schema}

  @type result :: {:ok, Parser.t()} | {:error, atom()}

  typedstruct do
    field(:raw_schema, map())
    field(:schema, Schema.t())
  end

  @doc """
  Walks the raw schema and produces a OpenAPI.Schema.t()
  """
  @spec parse_schema(raw_schema :: map()) :: Schema.t() | no_return()
  def parse_schema(%{} = raw_schema) do
    info =
      with %{} = raw_info <- Map.get(raw_schema, "info") do
        parse_info(raw_info)
      end

    servers =
      raw_schema
      |> Map.fetch!("servers")
      |> Enum.map(&parse_server/1)

    paths =
      raw_schema
      |> Map.fetch!("paths")
      |> parse_paths()

    %OpenAPI.Schema{
      info: info,
      servers: servers,
      paths: paths
    }
  end

  @spec parse_info(raw_info :: map()) :: Schema.Info.t()
  defp parse_info(%{} = raw_info) do
    %Schema.Info{
      title: Map.get(raw_info, "title"),
      description: Map.get(raw_info, "description"),
      version: Map.get(raw_info, "version")
    }
  end

  @spec parse_server(raw_server :: map()) :: Schema.Server.t()
  defp parse_server(%{} = raw_server) do
    %Schema.Server{url: Map.get(raw_server, "url")}
  end

  @spec parse_paths(raw_paths :: map()) :: %{
          required(path_name :: String.t()) => Schema.PathItem.t()
        }
  defp parse_paths(%{} = raw_paths) do
    Enum.reduce(raw_paths, %{}, fn {path_name, raw_path_item}, path_mapping ->
      Map.put(path_mapping, path_name, parse_path_item(raw_path_item))
    end)
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
    Enum.reduce(Schema.PathItem.all_operation_types(), %{}, fn operation_type,
                                                               operations_mapping ->
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

    parameters =
      with raw_parameters when is_list(raw_parameters) <- Map.get(raw_operation, "parameters") do
        Enum.map(raw_parameters, &parse_parameter/1)
      end

    %Schema.Operation{
      description: Map.get(raw_operation, "description"),
      request_body: request_body,
      parameters: parameters
    }
  end

  @spec parse_parameter(raw_parameter :: map()) :: Schema.Parameter.t()
  defp parse_parameter(%{} = raw_parameter) do
    parameter_location =
      with parameter_location when is_binary(parameter_location) <- Map.get(raw_parameter, "in") do
        parse_parameter_location(parameter_location)
      end

    data_schema =
      with %{} = raw_data_schema <- Map.get(raw_parameter, "schema") do
        parse_data_schema(raw_data_schema)
      end

    %Schema.Parameter{
      name: Map.get(raw_parameter, "name"),
      example: Map.get(raw_parameter, "example"),
      in: parameter_location,
      schema: data_schema
    }
  end

  @spec parse_parameter_location(raw_parameter_location :: String.t()) ::
          OpenAPI.Schema.Parameter.parameter_location()
  defp parse_parameter_location("query"), do: :query
  defp parse_parameter_location("header"), do: :header
  defp parse_parameter_location("path"), do: :path
  defp parse_parameter_location("cookie"), do: :cookie

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

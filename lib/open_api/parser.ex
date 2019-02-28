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

  @spec parse_path_item(raw_path_item :: map()) :: PathItem.t()
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
    %Schema.Operation{
      description: Map.get(raw_operation, "description")
    }
  end
end

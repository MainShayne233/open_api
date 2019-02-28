defmodule OpenAPI.Parser do
  @moduledoc """
  Parses a raw schema for eventual use by the builder.
  """
  use TypedStruct

  alias OpenAPI.{Parser, Schema}
  alias OpenAPI.Util.EnumUtil

  @type result :: {:ok, Parser.t()} | {:error, atom()}

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
             &parse_servers/1
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
end

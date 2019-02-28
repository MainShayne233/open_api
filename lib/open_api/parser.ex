defmodule OpenAPI.Parser do
  @moduledoc """
  Parses a raw schema for eventual use by the builder.
  """

  alias OpenAPI.Schema

  @type result :: {:ok, Schema.t()} | {:error, atom()}

  @doc """
  Walks the raw schema and produces a OpenAPI.Schema.t()
  """
  @spec parse_schema(raw_schema :: map()) :: result()
  def parse_schema(%{} = raw_schema) do
    {:ok, %Schema{}}
  end
end

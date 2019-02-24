defmodule OpenAPI do
  @moduledoc """
  Defines the OpenAPI macro to be `use`d in an API module.
  """

  alias OpenAPI.Parser

  @type ast :: tuple()

  @type raw_schema :: map()

  @type params :: [{:schema, raw_schema()}]

  @type result :: {:ok, ast()} | {:error, atom()}

  @spec __using__(raw_schema()) :: result()
  defmacro __using__(params) do
    IO.inspect(params)
    generate(params, __CALLER__.module)
  end

  @doc """
  Generates the AST to be compiled into the host module
  """
  @spec generate(params(), module()) :: result()
  def generate(params, parent_module) do
    schema = Keyword.fetch!(params, :schema)

    parser =
      %Parser{schema: schema}
      |> parse()

    {:ok,
     quote do
       nil
     end}
  end

  defp parse(parser) do
    parser
    |> parse_domain()
  end

  defp parse_domain(%Parser{schema: %{"servers" => [%{"url" => domain} | _]}} = parser) do
    %Parser{parser | domain: domain}
  end
end

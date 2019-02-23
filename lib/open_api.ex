defmodule OpenAPI do
  @moduledoc """
  Defines the OpenAPI macro to be `use`d in an API module.
  """

  @type ast :: tuple()

  @type raw_schema :: map()

  @type params :: [{:schema, raw_schema()}]

  @type result :: {:ok, ast()} | {:error, atom()}

  @spec __using__(raw_schema()) :: result()
  defmacro __using__(params) do
    IO.inspect __CALLER__
    generate(params)
  end

  @doc """
  Generates the AST to be compiled into the host module
  """
  @spec generate(params()) :: result()
  def generate(params) do
    # with {:ok, %OpenAPI.Spec{} = spec} <- OpenAPI.Parse.parse_spec_file(spec_file) do
    #   {:ok, spec}
    # end
  end
end

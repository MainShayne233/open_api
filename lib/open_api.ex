defmodule OpenAPI do
  @moduledoc """
  Defines the OpenAPI macro to be `use`d in an API module.
  """

  @type ast :: tuple()

  @type raw_schema :: map()

  @type params :: [{:schema, raw_schema()}]

  @spec __using__(raw_schema()) :: ast()
  defmacro __using__(params) do
    quote do
      @params unquote(params)

      @before_compile OpenAPI.Builder
    end
  end
end

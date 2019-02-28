defmodule OpenAPI.Schema.Parameters do
  use TypedStruct

  alias OpenAPI.Schema.DataSchema

  @type parameter_location :: :query | :header | :path | :cookie

  typedstruct do
    field(:name, String.t())
    field(:description, String.t())
    field(:in, parameter_location())
    field(:example, any())
    field(:schema, DataSchema.t())
  end
end

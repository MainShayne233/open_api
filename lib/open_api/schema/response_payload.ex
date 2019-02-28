defmodule OpenAPI.Schema.ResponsePayload do
  use TypedStruct

  alias OpenAPI.Schema.DataSchema

  typedstruct do
    field(:schema, DataSchema.t())
  end
end

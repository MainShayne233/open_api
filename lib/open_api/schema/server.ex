defmodule OpenAPI.Schema.Server do
  use TypedStruct

  typedstruct do
    field(:url, String.t())
  end
end

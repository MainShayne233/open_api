defmodule OpenAPI.Schema.Info do
  use TypedStruct

  typedstruct do
    field(:title, String.t())
    field(:description, String.t())
    field(:version, String.t())
  end
end

defmodule OpenAPI.Schema.RequestBody do
  use TypedStruct

  alias OpenAPI.Schema.RequestPayload

  typedstruct do
    field(:description, String.t())
    field(:content, %{required(media_type :: String.t()) => RequestPayload.t()})
  end
end

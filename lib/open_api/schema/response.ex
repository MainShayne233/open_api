defmodule OpenAPI.Schema.Response do
  use TypedStruct

  alias OpenAPI.Schema.ResponsePayload

  typedstruct do
    field(:description, String.t())
    field(:content, %{required(media_type :: String.t()) => ResponsePayload.t()})
  end
end

defmodule OpenAPI.Spec.Content.JSONContent do
  @moduledoc """
  Defines a struct that represents a JSON content blob for a request/respnse.
  """

  use TypedStruct

  typedstruct do
    field(:body, map())
  end
end

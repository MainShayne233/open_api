defmodule OpenAPI.Spec do
  @moduledoc """
  Defines a struct that represents an API spec
  """
  use TypedStruct

  typedstruct do
    field(:openapi, String.t())
    field(:description, String.t())
    field(:version, String.t())
    field(:servers, [String.t()])
    field(:paths, [OpenAPI.Spec.Path])
  end
end


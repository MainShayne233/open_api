defmodule OpenAPI.Spec.Path do
  @moduledoc """
  Defines a struct that represents an API path.
  """
  use TypedStruct

  typedstruct do
    field(:name, String.t())
  end
end

defmodule OpenAPI.Spec.Action do
  @moduledoc """
  Defines a struct that represents an API action.
  """
  use TypedStruct

  @type action_type :: :post

  typedstruct do
    field(:type, action_type())
  end
end

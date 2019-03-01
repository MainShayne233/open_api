defmodule OpenAPI.Schema.PathItem do
  use TypedStruct

  alias OpenAPI.Schema.{Operation, Parameter}

  typedstruct do
    field(:get, Operation.t())
    field(:put, Operation.t())
    field(:post, Operation.t())
    field(:delete, Operation.t())
    field(:options, Operation.t())
    field(:head, Operation.t())
    field(:patch, Operation.t())
    field(:trace, Operation.t())
    field(:parameters, [Parameter.t()])
  end
end

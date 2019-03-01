defmodule OpenAPI.Schema.PathItem do
  use TypedStruct

  alias OpenAPI.Schema.{Operation, Parameter}

  @type operation_type ::
          :get | :put | :post | :delete | :options | :head | :head | :patch | :trace

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

  @operation_types [
    :get,
    :put,
    :post,
    :delete,
    :options,
    :head,
    :patch,
    :trace
  ]

  @spec all_operation_types :: [operation_type()]
  def all_operation_types, do: @operation_types
end

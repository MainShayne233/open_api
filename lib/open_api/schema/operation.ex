defmodule OpenAPI.Schema.Operation do
  use TypedStruct

  alias OpenAPI.Schema.{Parameters, Response}

  typedstruct do
    field(:description, String.t())
    field(:parameters, Parameters.t())
    field(:responses, %{required(status_code :: integer()) => Response.t()})
  end
end

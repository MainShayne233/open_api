defmodule OpenAPI.Schema.Operation do
  use TypedStruct

  alias OpenAPI.Schema.{Parameter, RequestBody, Response}

  typedstruct do
    field(:description, String.t())
    field(:request_body, RequestBody.t())
    field(:parameters, [Parameter.t()])
    field(:responses, %{required(status_code :: integer()) => Response.t()})
  end
end

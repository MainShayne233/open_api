defmodule OpenAPI.HTTP.Request do
  use Breakfast

  cereal do
    field(:operation_type, :get | :post)
    field(:request_body, struct())
  end
end

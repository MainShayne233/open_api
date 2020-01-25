defmodule OpenAPI.V3.MediaType do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:schema, {:cereal, V3.Schema} | {:cereal, V3.Reference} | nil, default: nil)
    field(:example, any(), default: nil)

    field(
      :examples,
      %{required(String.t()) => {:cereal, V3.Example} | {:cereal, V3.Reference}} | nil,
      default: nil
    )
  end
end

defmodule OpenAPI.V3.Schema do
  @moduledoc false

  use Breakfast

  alias OpenAPI.V3

  cereal do
    field(:title, String.t() | nil, default: nil)
    field(:required, [String.t()], default: [])
    field(:type, String.t())

    field(:properties, %{required(name :: String.t()) => {:cereal, V3.Schema}} | nil, default: nil)

    field(:example, any(), default: nil)
  end
end

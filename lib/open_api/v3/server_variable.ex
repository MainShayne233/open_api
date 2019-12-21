defmodule OpenAPI.V3.ServerVariable do
  @moduledoc false

  use Breakfast

  cereal do
    field(:enum, [String.t()] | nil, default: nil)
    field(:default, String.t())
    field(:description, String.t() | nil, default: nil)
  end
end

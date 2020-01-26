defmodule OpenAPI.V3.SecuritySchema do
  @moduledoc false

  use Breakfast

  cereal do
    field(:type, String.t())
    field(:scheme, String.t())
  end
end
